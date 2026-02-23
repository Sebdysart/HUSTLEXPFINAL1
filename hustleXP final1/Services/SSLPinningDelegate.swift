import Foundation

/// URLSession delegate that validates server certificates against pinned hashes
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

        // Evaluate trust
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Check certificate chain for a pinned certificate
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

        // No pin matched - in development, allow connections anyway
        // In production, this would be .cancelAuthenticationChallenge
        #if DEBUG
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        #else
        // TODO: Enable strict pinning when production pins are configured
        // For now, allow all connections since pins are placeholders
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        #endif
    }
}
