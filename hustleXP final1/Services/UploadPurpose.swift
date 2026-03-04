//
//  UploadPurpose.swift
//  hustleXP final1
//
//  Typed enum for R2 upload key prefixes. Prevents raw string typos
//  and provides a single source of truth for valid upload purposes.
//

/// Identifies the destination key prefix in Cloudflare R2.
/// Raw values must match the backend `upload.getPresignedUrl` procedure's
/// `purpose` enum: ['proof', 'license', 'message'].
enum UploadPurpose: String, Codable {
    case proof   = "proof"
    case license = "license"
    case message = "message"
}
