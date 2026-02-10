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
    static let cancelledCode = -5

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
}
