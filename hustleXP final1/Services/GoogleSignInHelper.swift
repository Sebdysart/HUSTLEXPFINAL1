//
//  GoogleSignInHelper.swift
//  hustleXP final1
//
//  Google Sign-In helper using GoogleSignIn SDK
//

import UIKit
import GoogleSignIn

/// Helper for Google Sign-In integration
enum GIDSignInHelper {
    /// Legacy code kept for back-compat; prefer `isUserCancellation(_:)` for new code.
    static let cancelledCode = GIDSignInError.canceled.rawValue

    struct SignInResult {
        let idToken: String
        let accessToken: String
    }

    @MainActor
    static func signIn(withClientID clientID: String, presenting viewController: UIViewController) async throws -> SignInResult {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "GIDSignInHelper", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing Google ID token."])
        }

        return SignInResult(
            idToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
    }

    /// Returns true if the error represents the user explicitly cancelling
    /// the sign-in flow (vs. a real failure like missing URL scheme or no presenter).
    /// Checks both the new `GIDSignInError.canceled` enum and the raw int code
    /// for older SDK versions.
    static func isUserCancellation(_ error: Error) -> Bool {
        let nsError = error as NSError
        // Domain-aware check — only count as cancellation if it's actually from Google's SDK
        if nsError.domain == kGIDSignInErrorDomain {
            return nsError.code == GIDSignInError.canceled.rawValue
        }
        return false
    }

    /// Returns a user-friendly explanation for common Google Sign-In errors.
    /// Helps surface configuration issues (URL scheme missing, etc.) instead of
    /// the misleading "cancelled" message users see.
    static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == kGIDSignInErrorDomain {
            switch nsError.code {
            case GIDSignInError.canceled.rawValue:
                return "Sign-in cancelled."
            case GIDSignInError.hasNoAuthInKeychain.rawValue:
                return "No saved Google account found. Please sign in fresh."
            case GIDSignInError.EMM.rawValue:
                return "Your organization restricts this account."
            default:
                return "Google Sign-In failed: \(nsError.localizedDescription) (code \(nsError.code))"
            }
        }
        return error.localizedDescription
    }
}
