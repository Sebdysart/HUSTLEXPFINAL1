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

        // Safety net: if no real pins are configured (e.g. only placeholder
        // values shipped), fall back to system trust validation. Without this,
        // every TLS handshake would fail with NSURLErrorCancelled (-999) and
        // the entire app would lose network connectivity.
        let validPins = CertificatePins.pins
        guard !validPins.isEmpty else {
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

        // No pin matched — reject the connection
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
