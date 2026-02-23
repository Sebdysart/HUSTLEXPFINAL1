import Foundation
import CryptoKit

/// SSL certificate pins for the HustleXP backend
/// Update these when rotating TLS certificates
enum CertificatePins {
    /// Primary pin (Railway TLS certificate SHA-256)
    /// TODO: Replace with actual pin from production cert
    static let primary = "PLACEHOLDER_PRIMARY_PIN_SHA256"

    /// Backup pin (for certificate rotation)
    /// TODO: Replace with actual backup pin
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
