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

        // Enforce pin matching against certificate chain
        let certificateCount = SecTrustGetCertificateCount(serverTrust)

        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                continue
            }

            if let hash = CertificatePins.sha256(of: certificate),
               CertificatePins.pins.contains(hash) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }

        // No pin matched in release build — reject the connection
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
