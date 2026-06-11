import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit

/// Manages user authentication with Firebase and backend registration
///
/// Handles the complete authentication flow:
/// 1. Firebase Authentication (email/password)
/// 2. Backend user registration
/// 3. Token management and persistence
/// 4. Session state management
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    // MARK: - Demo Mode
    // Set to true to bypass Firebase and use mock authentication
    // This allows testing the app UI without a valid Firebase config
    static let isDemoMode = false

    @Published var currentUser: HXUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: Error?

    /// Social sign-in (Apple/Google) creates the Firebase user before we can ask
    /// for a date of birth — which the backend REQUIRES for registration
    /// (user.register zod schema: dateOfBirth YYYY-MM-DD). When set, the UI must
    /// present DateOfBirthPromptView and call completePendingRegistration(_:).
    @Published var needsDateOfBirth = false

    struct PendingSocialRegistration {
        let firebaseUid: String
        let email: String
        let fullName: String
        let idToken: String
        let analyticsMethod: String
    }
    private(set) var pendingSocialRegistration: PendingSocialRegistration?

    /// Backend contract: dateOfBirth must be YYYY-MM-DD (user.register schema).
    static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Reference to AppState for bridging auth state
    /// Set this from the app entry point after initialization
    var appState: AppState?

    private let trpc: TRPCClientProtocol

    init(client: TRPCClientProtocol = TRPCClient.shared) {
        self.trpc = client

        // In demo mode, skip Firebase token restoration
        guard !Self.isDemoMode else { return }

        // Load saved token and attempt to restore session
        if let trpcClient = client as? TRPCClient {
            trpcClient.loadAuthToken()
        }

        if KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) != nil {
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Sign Up

    /// Backend registration input — matches user.register zod schema EXACTLY:
    /// { idToken (REQUIRED), firebaseUid, email, fullName, defaultMode?, dateOfBirth (REQUIRED), phone? }
    /// idToken must be in the BODY (register is a publicProcedure; the auth header is ignored).
    private struct BackendRegisterInput: Codable {
        let idToken: String
        let firebaseUid: String
        let email: String
        let fullName: String
        let defaultMode: String
        let dateOfBirth: String
    }

    /// Single registration path for all three auth methods (email/Apple/Google).
    private func registerWithBackend(
        firebaseUid: String,
        email: String,
        fullName: String,
        defaultMode: UserRole,
        idToken: String,
        dateOfBirth: Date
    ) async throws -> HXUser {
        let input = BackendRegisterInput(
            idToken: idToken,
            firebaseUid: firebaseUid,
            email: email,
            fullName: fullName,
            defaultMode: defaultMode.rawValue,
            dateOfBirth: Self.dobFormatter.string(from: dateOfBirth)
        )
        return try await trpc.call(
            router: "user",
            procedure: "register",
            input: input
        )
    }

    /// Completes a social (Apple/Google) registration once the user provides
    /// their date of birth. The Firebase session and auth token are already live.
    func completePendingRegistration(dateOfBirth: Date) async throws {
        guard let pending = pendingSocialRegistration else { return }
        isLoading = true
        defer { isLoading = false }

        let user = try await registerWithBackend(
            firebaseUid: pending.firebaseUid,
            email: pending.email,
            fullName: pending.fullName,
            defaultMode: .hustler,
            idToken: pending.idToken,
            dateOfBirth: dateOfBirth
        )

        KeychainManager.shared.save(user.id, forKey: KeychainManager.Key.userId)
            HXLogger.setDiagnosticsUser(user.id)
        self.currentUser = user
        self.isAuthenticated = true
        self.needsDateOfBirth = false
        self.pendingSocialRegistration = nil
        appState?.login(userId: user.id, role: user.role)
        Task { await PushNotificationManager.shared.flushPendingToken() }

        HXLogger.info("Auth: Social sign-in registration completed - \(user.name)", category: "Auth")
        AnalyticsService.shared.track(.signUp, properties: ["method": pending.analyticsMethod])
    }

    /// Creates a new user account with Firebase and registers with backend
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - fullName: User's full name
    ///   - defaultMode: User's default role (worker or poster)
    ///   - dateOfBirth: REQUIRED by the backend (age verification, YYYY-MM-DD)
    func signUp(
        email: String,
        password: String,
        fullName: String,
        defaultMode: UserRole,
        dateOfBirth: Date
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        // Demo mode - create mock user without Firebase
        if Self.isDemoMode {
            try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

            let mockUser = HXUser(
                id: UUID().uuidString,
                name: fullName,
                email: email,
                phone: nil,
                bio: nil,
                avatarURL: nil,
                role: defaultMode,
                trustTier: .rookie,
                rating: 5.0,
                totalRatings: 0,
                xp: 0,
                tasksCompleted: 0,
                tasksPosted: 0,
                totalEarnings: 0,
                totalSpent: 0,
                isVerified: false,
                createdAt: Date()
            )

            self.currentUser = mockUser
            self.isAuthenticated = true
            appState?.login(userId: mockUser.id, role: mockUser.role)
            Task { await PushNotificationManager.shared.flushPendingToken() }

            HXLogger.info("Auth [DEMO]: User signed up successfully - \(mockUser.name)", category: "Auth")
            return
        }

        do {
            // Step 1: Create Firebase user
            let authResult = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )

            // Step 2: Get Firebase ID token
            let idToken = try await authResult.user.getIDToken()

            // Step 3: Register with backend (idToken + dateOfBirth are REQUIRED by the schema)
            let user = try await registerWithBackend(
                firebaseUid: authResult.user.uid,
                email: email,
                fullName: fullName,
                defaultMode: defaultMode,
                idToken: idToken,
                dateOfBirth: dateOfBirth
            )

            // Step 4: Store credentials and update state
            TRPCClient.shared.setAuthToken(idToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)
            KeychainManager.shared.save(user.id, forKey: KeychainManager.Key.userId)
            HXLogger.setDiagnosticsUser(user.id)

            self.currentUser = user
            self.isAuthenticated = true
            appState?.login(userId: user.id, role: user.role)
            Task { await PushNotificationManager.shared.flushPendingToken() }

            HXLogger.info("Auth: User signed up successfully - \(user.name)", category: "Auth")
            AnalyticsService.shared.track(.signUp, properties: ["method": "email"])
        } catch let error as NSError {
            self.error = error
            HXLogger.error("Auth: Sign up failed - \(error.localizedDescription)", category: "Auth")
            HXLogger.error("Auth: Error domain: \(error.domain), code: \(error.code)", category: "Auth")
            HXLogger.error("Auth: Full error: \(error)", category: "Auth")
            AnalyticsService.shared.trackError(error.localizedDescription, context: "signUp")
            throw error
        }
    }

    // MARK: - Sign In

    /// Signs in an existing user with Firebase
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Demo mode - create mock user without Firebase
        if Self.isDemoMode {
            try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

            let mockUser = HXUser(
                id: UUID().uuidString,
                name: "Demo User",
                email: email,
                phone: nil,
                bio: "Welcome to HustleXP Demo Mode!",
                avatarURL: nil,
                role: .hustler,
                trustTier: .verified,
                rating: 4.8,
                totalRatings: 12,
                xp: 250,
                tasksCompleted: 8,
                tasksPosted: 0,
                totalEarnings: 485.50,
                totalSpent: 0,
                isVerified: true,
                createdAt: Date().addingTimeInterval(-86400 * 30) // 30 days ago
            )

            self.currentUser = mockUser
            self.isAuthenticated = true
            appState?.login(userId: mockUser.id, role: mockUser.role)
            Task { await PushNotificationManager.shared.flushPendingToken() }

            HXLogger.info("Auth [DEMO]: User signed in successfully - \(mockUser.name)", category: "Auth")
            return
        }

        do {
            // Step 1: Sign in with Firebase
            let authResult = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )

            // Step 2: Get Firebase ID token
            let idToken = try await authResult.user.getIDToken()

            // Step 3: Store token
            TRPCClient.shared.setAuthToken(idToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)

            // Step 4: Load user from backend
            await loadCurrentUser()

            HXLogger.info("Auth: User signed in successfully", category: "Auth")
            AnalyticsService.shared.track(.signIn, properties: ["method": "email"])
        } catch let error as NSError {
            self.error = error
            HXLogger.error("Auth: Sign in failed - \(error.localizedDescription)", category: "Auth")
            HXLogger.error("Auth: Error domain: \(error.domain), code: \(error.code)", category: "Auth")
            HXLogger.error("Auth: Full error: \(error)", category: "Auth")
            AnalyticsService.shared.trackError(error.localizedDescription, context: "signIn")
            throw error
        }
    }

    // MARK: - Sign In with Apple

    /// Stored nonce for Apple Sign-In verification
    private var currentNonce: String?

    /// Signs in or registers a user with Apple credentials
    func signInWithApple(authorization: ASAuthorization) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AuthService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Unable to process Apple Sign-In credentials."])
        }

        do {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            let idToken = try await authResult.user.getIDToken()

            // Store token
            TRPCClient.shared.setAuthToken(idToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)

            // Try to load existing user from backend (silentFail: user may not exist yet)
            await loadCurrentUser(silentFail: true)
            if isAuthenticated {
                HXLogger.info("Auth: Apple Sign-In successful (existing user)", category: "Auth")
                return
            }

            // User doesn't exist on backend yet, register them
            let fullName = [
                appleIDCredential.fullName?.givenName,
                appleIDCredential.fullName?.familyName
            ].compactMap { $0 }.joined(separator: " ")

            let displayName = fullName.isEmpty
                ? (authResult.user.displayName ?? "HustleXP User")
                : fullName

            // Backend registration REQUIRES a date of birth, which Apple does not
            // provide. Stash the pending registration and let the UI collect DOB
            // (DateOfBirthPromptView → completePendingRegistration).
            self.pendingSocialRegistration = PendingSocialRegistration(
                firebaseUid: authResult.user.uid,
                email: authResult.user.email ?? "",
                fullName: displayName,
                idToken: idToken,
                analyticsMethod: "apple"
            )
            self.needsDateOfBirth = true
            HXLogger.info("Auth: Apple Sign-In needs date of birth to finish registration", category: "Auth")
        } catch let error as NSError {
            self.error = error
            HXLogger.error("Auth: Apple Sign-In failed - \(error.localizedDescription)", category: "Auth")
            AnalyticsService.shared.trackError(error.localizedDescription, context: "appleSignIn")
            throw error
        }
    }

    /// Prepares a crypto nonce for Apple Sign-In and returns the request
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    // MARK: - Sign In with Google

    /// Signs in or registers a user with Google credentials via Firebase
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            let firebaseToken = try await authResult.user.getIDToken()

            // Store token
            TRPCClient.shared.setAuthToken(firebaseToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)

            // Try to load existing user from backend (silentFail: user may not exist yet)
            await loadCurrentUser(silentFail: true)
            if isAuthenticated {
                HXLogger.info("Auth: Google Sign-In successful (existing user)", category: "Auth")
                return
            }

            // Backend registration REQUIRES a date of birth — collect via UI first.
            self.pendingSocialRegistration = PendingSocialRegistration(
                firebaseUid: authResult.user.uid,
                email: authResult.user.email ?? "",
                fullName: authResult.user.displayName ?? "HustleXP User",
                idToken: firebaseToken,
                analyticsMethod: "google"
            )
            self.needsDateOfBirth = true
            HXLogger.info("Auth: Google Sign-In needs date of birth to finish registration", category: "Auth")
        } catch let error as NSError {
            self.error = error
            HXLogger.error("Auth: Google Sign-In failed - \(error.localizedDescription)", category: "Auth")
            AnalyticsService.shared.trackError(error.localizedDescription, context: "googleSignIn")
            throw error
        }
    }

    // MARK: - Sign Out

    /// Signs out the current user and clears all stored credentials
    func signOut() {
        // Deregister push token before clearing credentials
        Task { await PushNotificationManager.shared.deregisterCurrentToken() }

        // Demo mode - just clear state
        if Self.isDemoMode {
            currentUser = nil
            isAuthenticated = false
            appState?.logout()
            HXLogger.info("Auth [DEMO]: User signed out successfully", category: "Auth")
            return
        }

        do {
            try Auth.auth().signOut()
            TRPCClient.shared.clearAuthToken()
            KeychainManager.shared.delete(forKey: KeychainManager.Key.authToken)
            KeychainManager.shared.delete(forKey: KeychainManager.Key.firebaseUid)
            KeychainManager.shared.delete(forKey: KeychainManager.Key.userId)

            currentUser = nil
            isAuthenticated = false
            appState?.logout()

            HXLogger.info("Auth: User signed out successfully", category: "Auth")
            AnalyticsService.shared.track(.signOut)
            Task { await AnalyticsService.shared.flush() }
        } catch {
            HXLogger.error("Auth: Sign out error - \(error.localizedDescription)", category: "Auth")
        }
    }

    // MARK: - Load Current User

    /// Loads the current user's profile from the backend
    /// - Parameter silentFail: When `true` the method won't call `signOut()` on
    ///   failure.  This is used during the sign-in / registration flow where a
    ///   missing backend user is expected (the caller will register instead).
    private func loadCurrentUser(silentFail: Bool = false) async {
        do {
            struct EmptyInput: Codable {}

            let user: HXUser = try await trpc.call(
                router: "user",
                procedure: "me",
                type: .query,
                input: EmptyInput()
            )

            self.currentUser = user
            self.isAuthenticated = true
            HXLogger.setDiagnosticsUser(user.id)
            appState?.login(userId: user.id, role: user.role)
            Task { await PushNotificationManager.shared.flushPendingToken() }

            // Store user ID
            KeychainManager.shared.save(user.id, forKey: KeychainManager.Key.userId)
            HXLogger.setDiagnosticsUser(user.id)

            HXLogger.info("Auth: Loaded current user - \(user.name)", category: "Auth")
        } catch {
            HXLogger.error("Auth: Failed to load current user - \(error.localizedDescription)", category: "Auth")
            if silentFail {
                // Caller will handle registration; don't destroy auth token
                return
            }
            // Token may be expired or invalid, sign out
            signOut()
        }
    }

    // MARK: - Token Refresh

    /// Refreshes the Firebase ID token
    /// Call this periodically or when receiving 401 errors
    func refreshToken() async throws {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw APIError.unauthorized
        }

        let idToken = try await firebaseUser.getIDToken(forcingRefresh: true)
        TRPCClient.shared.setAuthToken(idToken)

        HXLogger.info("Auth: Token refreshed successfully", category: "Auth")
    }

    // MARK: - Password Reset

    /// Sends a password reset email
    /// - Parameter email: User's email address
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        HXLogger.info("Auth: Password reset email sent to \(email)", category: "Auth")
    }

    // MARK: - Crypto Helpers

    /// Generates a random nonce string for Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    /// SHA256 hash of the input string
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
