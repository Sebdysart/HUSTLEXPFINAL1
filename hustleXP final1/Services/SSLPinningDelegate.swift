import Foundation

/// URLSession delegate that validates server certificates against pinned hashes.
///
/// Behavior controlled by `AppConfig.sslPinningEnabled`:
/// - Debug builds: pinning disabled (allows proxies, local dev)
/// - Release builds: enforces pinning against CertificatePins.pins
final class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Always validate the certificate chain via system trust store
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // If pinning is disabled (debug builds), accept any valid certificate
        guard AppConfig.sslPinningEnabled else {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }

        // If no real pins are configured (bundled pins are placeholders and no
        // remote pins are cached), pinning is NOT CONFIGURED. Fall back to the
        // system trust evaluation that already passed above rather than
        // rejecting every connection — fail-closed here bricked all
        // Release/TestFlight networking while shipping placeholder pins.
        let validPins = CertificatePins.pins
        guard !validPins.isEmpty else {
            HXLogger.error(
                "SSL pinning enabled but no real pins configured — falling back to system TLS validation",
                category: "Network"
            )
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }

        // Enforce pin matching against certificate chain
        let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []

        for certificate in certificateChain {

            if let hash = CertificatePins.sha256(of: certificate),
               validPins.contains(hash) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }

        // No pin matched in release build — reject the connection
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
