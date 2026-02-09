import Foundation
import Combine
import FirebaseAuth
import FirebaseCore

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

    private let trpc = TRPCClient.shared

    private init() {
        // In demo mode, skip Firebase token restoration
        guard !Self.isDemoMode else { return }

        // Load saved token and attempt to restore session
        trpc.loadAuthToken()

        if KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) != nil {
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Sign Up

    /// Creates a new user account with Firebase and registers with backend
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - fullName: User's full name
    ///   - defaultMode: User's default role (worker or poster)
    func signUp(
        email: String,
        password: String,
        fullName: String,
        defaultMode: UserRole
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

            print("✅ Auth [DEMO]: User signed up successfully - \(mockUser.name)")
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

            // Step 3: Register with backend
            struct RegisterInput: Codable {
                let firebaseUid: String
                let email: String
                let fullName: String
                let defaultMode: String
            }

            let input = RegisterInput(
                firebaseUid: authResult.user.uid,
                email: email,
                fullName: fullName,
                defaultMode: defaultMode.rawValue
            )

            let user: HXUser = try await trpc.call(
                router: "user",
                procedure: "register",
                input: input
            )

            // Step 4: Store credentials and update state
            trpc.setAuthToken(idToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)
            KeychainManager.shared.save(user.id, forKey: KeychainManager.Key.userId)

            self.currentUser = user
            self.isAuthenticated = true

            print("✅ Auth: User signed up successfully - \(user.name)")
        } catch let error as NSError {
            self.error = error
            print("❌ Auth: Sign up failed - \(error.localizedDescription)")
            print("❌ Auth: Error domain: \(error.domain), code: \(error.code)")
            print("❌ Auth: Full error: \(error)")
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

            print("✅ Auth [DEMO]: User signed in successfully - \(mockUser.name)")
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
            trpc.setAuthToken(idToken)
            KeychainManager.shared.save(authResult.user.uid, forKey: KeychainManager.Key.firebaseUid)

            // Step 4: Load user from backend
            await loadCurrentUser()

            print("✅ Auth: User signed in successfully")
        } catch let error as NSError {
            self.error = error
            print("❌ Auth: Sign in failed - \(error.localizedDescription)")
            print("❌ Auth: Error domain: \(error.domain), code: \(error.code)")
            print("❌ Auth: Full error: \(error)")
            throw error
        }
    }

    // MARK: - Sign Out

    /// Signs out the current user and clears all stored credentials
    func signOut() {
        // Demo mode - just clear state
        if Self.isDemoMode {
            currentUser = nil
            isAuthenticated = false
            print("✅ Auth [DEMO]: User signed out successfully")
            return
        }

        do {
            try Auth.auth().signOut()
            trpc.clearAuthToken()
            KeychainManager.shared.delete(forKey: KeychainManager.Key.authToken)
            KeychainManager.shared.delete(forKey: KeychainManager.Key.firebaseUid)
            KeychainManager.shared.delete(forKey: KeychainManager.Key.userId)

            currentUser = nil
            isAuthenticated = false

            print("✅ Auth: User signed out successfully")
        } catch {
            print("⚠️ Auth: Sign out error - \(error.localizedDescription)")
        }
    }

    // MARK: - Load Current User

    /// Loads the current user's profile from the backend
    private func loadCurrentUser() async {
        do {
            struct EmptyInput: Codable {}

            let user: HXUser = try await trpc.call(
                router: "user",
                procedure: "me",
                input: EmptyInput()
            )

            self.currentUser = user
            self.isAuthenticated = true

            // Store user ID
            KeychainManager.shared.save(user.id, forKey: KeychainManager.Key.userId)

            print("✅ Auth: Loaded current user - \(user.name)")
        } catch {
            print("⚠️ Auth: Failed to load current user - \(error.localizedDescription)")
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
        trpc.setAuthToken(idToken)

        print("✅ Auth: Token refreshed successfully")
    }

    // MARK: - Password Reset

    /// Sends a password reset email
    /// - Parameter email: User's email address
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        print("✅ Auth: Password reset email sent to \(email)")
    }
}
