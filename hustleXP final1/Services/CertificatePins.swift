import Foundation
import CryptoKit

/// SSL certificate pins for the HustleXP backend (Railway TLS).
///
/// HOW TO GET REAL PINS (hex-encoded SHA-256 of raw public key):
/// The RECOMMENDED approach is to run this app in DEBUG mode, connect to your server,
/// and log the output of `CertificatePins.sha256(of:)` — this guarantees the pin
/// matches what the runtime computes via `SecKeyCopyExternalRepresentation`.
///
/// Alternatively, for RSA keys you can try:
/// `openssl s_client -connect hustlexp-ai-backend-production.up.railway.app:443 < /dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 | awk '{print $2}'`
/// ⚠️ WARNING: The openssl pipeline hashes the SPKI DER (which includes the algorithm
/// OID wrapper), while `SecKeyCopyExternalRepresentation` returns raw key bytes WITHOUT
/// the wrapper. For RSA keys the difference is ~24 bytes of ASN.1 header. The hashes
/// WILL NOT MATCH unless you strip the SPKI header or use the debug-mode approach above.
///
/// NOTE: Pins use hex encoding (not base64) to match the internal sha256(of:) function.
/// The remote /api/ssl-pins endpoint MUST also serve hex-encoded pins.
///
/// Pinning is only enforced in release builds (see AppConfig.sslPinningEnabled).
/// Debug/TestFlight builds bypass pinning for development flexibility.
///
/// PIN ROTATION:
/// Railway (and most cloud hosts) rotate TLS certificates periodically.
/// This implementation supports rotation without requiring an app update:
/// 1. Bundled pins are compiled into the binary as a baseline.
/// 2. On launch, the app fetches a remote pin manifest from a known endpoint.
/// 3. Remote pins are cached in UserDefaults with a TTL.
/// 4. If remote fetch fails, bundled pins are used as fallback.
/// 5. Both leaf AND intermediate CA pins are supported for resilience.
enum CertificatePins {

    // MARK: - Bundled Pins (compiled into binary)

    /// Primary pin (Railway TLS leaf certificate SHA-256)
    /// REPLACE before enabling pinning in production release builds.
    /// Generate with the openssl command in the header comment.
    static let primary = "PLACEHOLDER_PRIMARY_PIN_SHA256"

    /// Backup pin (intermediate CA -- survives leaf rotation)
    /// REPLACE before enabling pinning in production release builds.
    static let backup = "PLACEHOLDER_BACKUP_PIN_SHA256"

    /// Bundled pins shipped with this binary (fallback if remote unavailable)
    static let bundledPins: [String] = [primary, backup]

    // MARK: - Remote Pin Rotation

    /// UserDefaults key for cached remote pins
    private static let remotePinsCacheKey = "com.hustlexp.ssl.remotePins"
    /// UserDefaults key for cache timestamp
    private static let remotePinsCacheDateKey = "com.hustlexp.ssl.remotePinsDate"
    /// Cache TTL: 24 hours (pins refresh daily)
    private static let cacheTTL: TimeInterval = 86_400

    /// Remote manifest URL -- serves a JSON array of valid hex-encoded SHA-256 pin hashes.
    /// Example response: `{ "pins": ["a1b2c3d4...64chars", "e5f6a7b8...64chars"], "version": 2 }`
    /// IMPORTANT: Pins must be hex-encoded (not base64) to match the internal sha256(of:) output.
    /// Host this on a CDN or your backend at a stable, non-pinned endpoint.
    static let remotePinManifestURL: URL? = {
        URL(string: "\(AppConfig.backendBaseURL.absoluteString)/api/ssl-pins")
    }()

    // MARK: - Effective Pins (bundled + cached remote)

    /// All currently valid pins: union of bundled + cached remote pins.
    /// This is what SSLPinningDelegate checks against.
    static var pins: [String] {
        var allPins = Set(bundledPins)

        // Merge cached remote pins if still fresh
        if let cached = cachedRemotePins, isCacheFresh {
            allPins.formUnion(cached)
        }

        return Array(allPins)
    }

    /// Cached remote pins from UserDefaults
    private static var cachedRemotePins: [String]? {
        UserDefaults.standard.stringArray(forKey: remotePinsCacheKey)
    }

    /// Whether the cached pins are still within TTL
    private static var isCacheFresh: Bool {
        guard let cacheDate = UserDefaults.standard.object(forKey: remotePinsCacheDateKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(cacheDate) < cacheTTL
    }

    // MARK: - Remote Refresh

    /// Fetch updated pins from the remote manifest.
    /// Call this on app launch (in a background task) to keep pins current.
    /// Uses a plain URLSession WITHOUT pinning to avoid the bootstrap problem.
    static func refreshRemotePins() async {
        guard AppConfig.sslPinningEnabled,
              let manifestURL = remotePinManifestURL else {
            return
        }

        do {
            // Use the shared session (no pinning) to fetch the pin manifest.
            // The manifest itself is integrity-checked by TLS to the system trust store.
            // NOTE: Using .shared avoids resource leaks from un-invalidated sessions.
            let (data, response) = try await URLSession.shared.data(from: manifestURL)

            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                return
            }

            let manifest = try JSONDecoder().decode(PinManifest.self, from: data)

            // Validate: pins must be exactly 64 hex chars (SHA-256 = 32 bytes = 64 hex digits)
            let validPins = manifest.pins.filter { pin in
                pin.count == 64 && pin.allSatisfy { $0.isHexDigit }
            }

            guard !validPins.isEmpty else { return }

            // Cache the valid remote pins
            UserDefaults.standard.set(validPins, forKey: remotePinsCacheKey)
            UserDefaults.standard.set(Date(), forKey: remotePinsCacheDateKey)
        } catch {
            // Silently fail -- bundled pins remain as fallback
            #if DEBUG
            print("[CertificatePins] Remote pin refresh failed: \(error.localizedDescription)")
            #endif
        }
    }

    /// Clear cached remote pins (e.g., on logout or for testing)
    static func clearCachedPins() {
        UserDefaults.standard.removeObject(forKey: remotePinsCacheKey)
        UserDefaults.standard.removeObject(forKey: remotePinsCacheDateKey)
    }

    // MARK: - Pin Computation

    /// Compute SHA-256 hash of a certificate's raw public key bytes.
    ///
    /// NOTE: `SecKeyCopyExternalRepresentation` returns the raw key material
    /// (PKCS#1 for RSA, ANSI X9.63 for EC) — NOT the full SPKI DER wrapper.
    /// The openssl command in the header comment must therefore also hash the
    /// raw public key, not the SPKI. Use:
    /// ```
    /// openssl s_client -connect <host>:443 < /dev/null 2>/dev/null \
    ///   | openssl x509 -pubkey -noout \
    ///   | openssl pkey -pubin -outform DER \
    ///   | openssl dgst -sha256 \
    ///   | awk '{print $2}'
    /// ```
    /// This pipeline extracts the SPKI DER then hashes it. If your server uses
    /// EC keys, the SPKI DER includes the algorithm OID prefix that
    /// `SecKeyCopyExternalRepresentation` omits. In that case, you may need to
    /// prepend the appropriate ASN.1 header before hashing, or generate pins by
    /// running this app in debug mode and logging the output of this function.
    ///
    /// Returns the hex-encoded hash string for comparison against known pins.
    static func sha256(of certificate: SecCertificate) -> String? {
        guard let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
            return nil
        }
        let hash = SHA256.hash(data: publicKeyData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Pin Manifest Model

/// JSON model for the remote pin manifest endpoint.
/// Example: `{ "pins": ["abc...", "def..."], "version": 2 }`
private struct PinManifest: Decodable {
    let pins: [String]
    /// Optional version field for audit/logging
    let version: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pins = try container.decode([String].self, forKey: .pins)
        self.version = try container.decodeIfPresent(Int.self, forKey: .version)
    }

    private enum CodingKeys: String, CodingKey {
        case pins
        case version
    }
}
