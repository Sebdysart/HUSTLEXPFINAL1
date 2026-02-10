//
//  GoogleSignInHelper.swift
//  hustleXP final1
//
//  Google Sign-In helper using GoogleSignIn SDK
//  Requires: GoogleSignIn-iOS SPM package
//  Add in Xcode: File > Add Package Dependencies
//  URL: https://github.com/google/GoogleSignIn-iOS
//

import UIKit

/// Helper for Google Sign-In integration
/// Once GoogleSignIn-iOS SPM package is added, replace the placeholder
/// implementation below with the real GIDSignIn calls.
enum GIDSignInHelper {
    static let cancelledCode = -5

    struct SignInResult {
        let idToken: String
        let accessToken: String
    }

    @MainActor
    static func signIn(withClientID clientID: String, presenting viewController: UIViewController) async throws -> SignInResult {
        // ──────────────────────────────────────────────────────────
        // TODO: Uncomment the real implementation below after adding
        // the GoogleSignIn-iOS SPM package to the project.
        //
        // Steps to enable:
        // 1. In Xcode: File > Add Package Dependencies
        // 2. Enter: https://github.com/google/GoogleSignIn-iOS
        // 3. Add "GoogleSignIn" product to your target
        // 4. Add REVERSED_CLIENT_ID as a URL scheme in Info.plist:
        //    URL Schemes: com.googleusercontent.apps.809490755123-s6vb7d09if2v8mtcpf4oeh3rsfcnqfml
        // 5. Uncomment the code below and remove the placeholder throw
        // ──────────────────────────────────────────────────────────

        /*
        import GoogleSignIn

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
        */

        throw NSError(
            domain: "GIDSignInHelper",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In requires setup. Add the GoogleSignIn-iOS SPM package in Xcode to enable this feature."]
        )
    }
}
