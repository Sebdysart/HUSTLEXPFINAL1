import Foundation
import CryptoKit

/// SSL certificate pins for the HustleXP backend (Railway TLS).
///
/// HOW TO GET REAL PINS:
/// 1. Run: `openssl s_client -connect hustlexp-ai-backend-production.up.railway.app:443 < /dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64`
/// 2. Copy the output as the primary pin.
/// 3. Repeat for the backup pin (use a different certificate in the chain).
///
/// Pinning is only enforced in release builds (see AppConfig.sslPinningEnabled).
/// Debug/TestFlight builds bypass pinning for development flexibility.
enum CertificatePins {
    /// Primary pin (Railway TLS leaf certificate SHA-256)
    /// REPLACE before enabling pinning in production release builds
    static let primary = "PLACEHOLDER_PRIMARY_PIN_SHA256"

    /// Backup pin (intermediate CA — survives leaf rotation)
    /// REPLACE before enabling pinning in production release builds
    static let backup = "PLACEHOLDER_BACKUP_PIN_SHA256"

    /// All valid pins
    static let pins: [String] = [primary, backup]

    /// Compute SHA-256 hash of certificate's public key
    static func sha256(of certificate: SecCertificate) -> String? {
        guard let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
            return nil
        }
        let hash = SHA256.hash(data: publicKeyData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
