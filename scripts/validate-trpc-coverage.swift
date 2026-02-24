#!/usr/bin/env swift

import Foundation

// MARK: - Models

struct TypeManifest: Codable {
    let generatedAt: String
    let backendSha: String
    let procedures: [ManifestProcedure]
}

struct ManifestProcedure: Codable {
    let router: String
    let name: String
    let type: String
    let authLevel: String
}

struct IOSCall: Hashable {
    let router: String
    let procedure: String
}

// Cross-surface manifest models
struct ErrorManifest: Codable {
    let generatedAt: String
    let codes: [ErrorManifestEntry]
}

struct ErrorManifestEntry: Codable {
    let code: String
    let message: String
    let category: String
}

struct FlagManifest: Codable {
    let generatedAt: String
    let flags: [String]
}

// MARK: - File scanning

func findSwiftFiles(in directory: String) -> [String] {
    let fm = FileManager.default
    var results: [String] = []
    guard let enumerator = fm.enumerator(atPath: directory) else {
        return results
    }
    while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".swift") {
            results.append((directory as NSString).appendingPathComponent(file))
        }
    }
    return results
}

func extractHXCodes(from filePath: String) -> Set<String> {
    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        return []
    }
    var codes = Set<String>()
    let pattern = #"HX\d{3}"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return []
    }
    let range = NSRange(content.startIndex..., in: content)
    let matches = regex.matches(in: content, range: range)
    for match in matches {
        if let matchRange = Range(match.range, in: content) {
            codes.insert(String(content[matchRange]))
        }
    }
    return codes
}

func extractFlagNames(from filePath: String) -> Set<String> {
    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        return []
    }
    var flags = Set<String>()
    let pattern = #"isEnabled\(\s*"([^"]+)"\s*\)"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return []
    }
    let range = NSRange(content.startIndex..., in: content)
    let matches = regex.matches(in: content, range: range)
    for match in matches {
        if match.numberOfRanges >= 2,
           let flagRange = Range(match.range(at: 1), in: content) {
            flags.insert(String(content[flagRange]))
        }
    }
    return flags
}

func extractTRPCCalls(from filePath: String) -> [IOSCall] {
    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        return []
    }
    var calls: [IOSCall] = []
    // Pattern: trpc.call(router: "(\w+)", procedure: "(\w+)"
    let pattern = #"trpc\.call\(router:\s*"(\w+)",\s*procedure:\s*"(\w+)""#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return []
    }
    let range = NSRange(content.startIndex..., in: content)
    let matches = regex.matches(in: content, range: range)
    for match in matches {
        if match.numberOfRanges >= 3,
           let routerRange = Range(match.range(at: 1), in: content),
           let procRange = Range(match.range(at: 2), in: content) {
            calls.append(IOSCall(
                router: String(content[routerRange]),
                procedure: String(content[procRange])
            ))
        }
    }
    return calls
}

// MARK: - Main

let servicesDir = "hustleXP final1/Services"
let manifestPath = "type-manifest.json"
let payloadPath = "backend-payload.json"

print("=== tRPC Contract Coverage Validator ===")
print("")

// Scan iOS service files for tRPC calls
let swiftFiles = findSwiftFiles(in: servicesDir)
var allCalls = Set<IOSCall>()

for file in swiftFiles {
    let calls = extractTRPCCalls(from: file)
    allCalls.formUnion(calls)
}

print("iOS tRPC calls found: \(allCalls.count)")
for call in allCalls.sorted(by: { "\($0.router).\($0.procedure)" < "\($1.router).\($1.procedure)" }) {
    print("  - \(call.router).\(call.procedure)")
}
print("")

// Try to load backend type manifest
let fm = FileManager.default

if fm.fileExists(atPath: manifestPath),
   let data = fm.contents(atPath: manifestPath),
   let manifest = try? JSONDecoder().decode(TypeManifest.self, from: data) {

    print("Backend manifest loaded (SHA: \(manifest.backendSha))")
    print("Backend procedures: \(manifest.procedures.count)")
    print("")

    // Build set of backend procedure keys
    let backendSet = Set(manifest.procedures.map { "\($0.router).\($0.name)" })
    let iosSet = Set(allCalls.map { "\($0.router).\($0.procedure)" })

    // Backend procedures NOT called by iOS
    let uncalledByIOS = backendSet.subtracting(iosSet).sorted()
    if !uncalledByIOS.isEmpty {
        print("Backend procedures NOT called by iOS (\(uncalledByIOS.count)):")
        for proc in uncalledByIOS {
            print("  [uncovered] \(proc)")
        }
        print("")
    }

    // iOS calls to procedures NOT in the manifest (obsolete)
    let obsoleteCalls = iosSet.subtracting(backendSet).sorted()
    if !obsoleteCalls.isEmpty {
        print("iOS calls to procedures NOT in backend manifest (\(obsoleteCalls.count)):")
        for proc in obsoleteCalls {
            print("  [obsolete] \(proc)")
        }
        print("")
    }

    if uncalledByIOS.isEmpty && obsoleteCalls.isEmpty {
        print("Perfect coverage: all backend procedures are called, no obsolete iOS calls.")
    }

} else if fm.fileExists(atPath: payloadPath),
          let data = fm.contents(atPath: payloadPath) {

    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        let sha = json["backend_sha"] as? String ?? "unknown"
        let prNumber = json["pr_number"] as? String ?? "unknown"
        print("Backend PR #\(prNumber) (SHA: \(sha)) triggered this check.")
        print("No type manifest artifact available -- skipping cross-repo comparison.")
    }

} else {
    print("No type manifest or backend payload found.")
    print("Run this during a repository_dispatch event or provide type-manifest.json.")
}

// ==========================================================================
// Cross-Surface: Error Code Validation
// ==========================================================================

print("=== Error Code Cross-Surface Validation ===")
print("")

let appDir = "hustleXP final1"
let allSwiftFiles = findSwiftFiles(in: appDir)
var iosHXCodes = Set<String>()

for file in allSwiftFiles {
    let codes = extractHXCodes(from: file)
    iosHXCodes.formUnion(codes)
}

print("iOS HX error codes found: \(iosHXCodes.count)")
for code in iosHXCodes.sorted() {
    print("  - \(code)")
}
print("")

let errorManifestPath = "error-manifest.json"
if fm.fileExists(atPath: errorManifestPath),
   let errorData = fm.contents(atPath: errorManifestPath),
   let errorManifest = try? JSONDecoder().decode(ErrorManifest.self, from: errorData) {

    let backendCodes = Set(errorManifest.codes.map { $0.code })

    // iOS codes NOT in backend registry (potentially obsolete)
    let obsoleteHXCodes = iosHXCodes.subtracting(backendCodes).sorted()
    if !obsoleteHXCodes.isEmpty {
        print("iOS error codes NOT in backend registry (\(obsoleteHXCodes.count)):")
        for code in obsoleteHXCodes {
            print("  [obsolete] \(code)")
        }
        print("")
    }

    // Backend codes NOT referenced in iOS (informational)
    let uncoveredHXCodes = backendCodes.subtracting(iosHXCodes).sorted()
    if !uncoveredHXCodes.isEmpty {
        print("Backend error codes NOT referenced in iOS (\(uncoveredHXCodes.count)):")
        for code in uncoveredHXCodes {
            print("  [uncovered] \(code)")
        }
        print("")
    }

    if obsoleteHXCodes.isEmpty && uncoveredHXCodes.isEmpty {
        print("Perfect error code coverage.")
    }
} else {
    print("No error-manifest.json found -- skipping error code comparison.")
}

print("")

// ==========================================================================
// Cross-Surface: Feature Flag Validation
// ==========================================================================

print("=== Feature Flag Cross-Surface Validation ===")
print("")

var iosFlags = Set<String>()
for file in allSwiftFiles {
    let flags = extractFlagNames(from: file)
    iosFlags.formUnion(flags)
}

print("iOS feature flag references found: \(iosFlags.count)")
for flag in iosFlags.sorted() {
    print("  - \(flag)")
}
print("")

let flagManifestPath = "flag-manifest.json"
if fm.fileExists(atPath: flagManifestPath),
   let flagData = fm.contents(atPath: flagManifestPath),
   let flagManifest = try? JSONDecoder().decode(FlagManifest.self, from: flagData) {

    let backendFlags = Set(flagManifest.flags)

    // iOS flags NOT in backend (unknown)
    let unknownFlags = iosFlags.subtracting(backendFlags).sorted()
    if !unknownFlags.isEmpty {
        print("iOS flags NOT in backend (\(unknownFlags.count)):")
        for flag in unknownFlags {
            print("  [unknown] \(flag)")
        }
        print("")
    }

    // Backend flags NOT referenced in iOS (informational)
    let unusedFlags = backendFlags.subtracting(iosFlags).sorted()
    if !unusedFlags.isEmpty {
        print("Backend flags NOT referenced in iOS (\(unusedFlags.count)):")
        for flag in unusedFlags {
            print("  [unused] \(flag)")
        }
        print("")
    }

    if unknownFlags.isEmpty && unusedFlags.isEmpty {
        print("Perfect feature flag coverage.")
    }
} else {
    print("No flag-manifest.json found -- skipping feature flag comparison.")
}

print("")
print("=== Validation complete ===")

// Always exit 0 -- informational only for now
exit(0)
