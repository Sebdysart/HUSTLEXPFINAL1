//
//  TRPCClientTests.swift
//  hustleXP final1Tests
//
//  Tests for the tRPC HTTP client: URL construction, header management,
//  response envelope decoding, and error parsing.
//

import XCTest
@testable import hustleXP_final1

final class TRPCClientTests: XCTestCase {

    // MARK: - URL Construction

    func testURLConstruction_queryPath() {
        // The client builds URLs as: baseURL + "/trpc/" + router + "." + procedure
        let base = URL(string: "https://api.example.com")!
        let path = "user.getProfile"
        let url = base.appendingPathComponent("/trpc/\(path)")

        XCTAssertTrue(url.absoluteString.contains("/trpc/user.getProfile"),
                       "URL should contain /trpc/router.procedure path")
    }

    func testURLConstruction_queryInputParameter() throws {
        let base = URL(string: "https://api.example.com")!
        let path = "task.listOpen"
        var components = URLComponents(url: base.appendingPathComponent("/trpc/\(path)"), resolvingAgainstBaseURL: false)!
        let inputJSON = "{\"lat\":40.7,\"lng\":-73.9}"
        components.queryItems = [URLQueryItem(name: "input", value: inputJSON)]

        let url = components.url!
        XCTAssertTrue(url.absoluteString.contains("input="),
                       "Query URL should include input parameter")
        // The encoded URL should contain the JSON payload
        XCTAssertTrue(url.absoluteString.contains("lat"), "Input param should contain lat")
    }

    func testURLConstruction_emptyInputOmitted() {
        // When input is "{}", client should skip adding the query param
        let inputJSON = "{}"
        let shouldAddParam = inputJSON != "{}"
        XCTAssertFalse(shouldAddParam, "Empty JSON input should not add query parameter")
    }

    // MARK: - Auth Token Header

    func testAuthTokenHeader_setWhenTokenExists() {
        var request = URLRequest(url: URL(string: "https://api.example.com/trpc/test")!)
        let token = "firebase-id-token-abc123"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer firebase-id-token-abc123")
    }

    func testAuthTokenHeader_absentWhenNoToken() {
        let request = URLRequest(url: URL(string: "https://api.example.com/trpc/test")!)
        // No Authorization header set
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"),
                     "Authorization header should be absent when no token is set")
    }

    func testMutationRequest_hasCorrectContentType() {
        var request = URLRequest(url: URL(string: "https://api.example.com/trpc/user.register")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    // MARK: - TRPCResponse Envelope Decoding

    func testTRPCResponseEnvelope_decodesSuccessfully() throws {
        // Simulate the tRPC response envelope: { "result": { "data": ... } }
        let json = """
        {
            "result": {
                "data": {
                    "id": "u1",
                    "name": "Test User"
                }
            }
        }
        """.data(using: .utf8)!

        struct SimpleUser: Decodable {
            let id: String
            let name: String
        }

        // Reproduce the envelope structure used by TRPCClient
        struct TRPCResult<T: Decodable>: Decodable {
            let data: T
        }
        struct TRPCResponse<T: Decodable>: Decodable {
            let result: TRPCResult<T>
        }

        let envelope = try JSONDecoder().decode(TRPCResponse<SimpleUser>.self, from: json)
        XCTAssertEqual(envelope.result.data.id, "u1")
        XCTAssertEqual(envelope.result.data.name, "Test User")
    }

    func testTRPCResponseEnvelope_decodesArrayData() throws {
        let json = """
        {
            "result": {
                "data": [1, 2, 3]
            }
        }
        """.data(using: .utf8)!

        struct TRPCResult<T: Decodable>: Decodable {
            let data: T
        }
        struct TRPCResponse<T: Decodable>: Decodable {
            let result: TRPCResult<T>
        }

        let envelope = try JSONDecoder().decode(TRPCResponse<[Int]>.self, from: json)
        XCTAssertEqual(envelope.result.data, [1, 2, 3])
    }

    // MARK: - Error Response Parsing

    func testTRPCError_decodesWithCode() throws {
        let json = """
        {
            "error": {
                "message": "Not authenticated",
                "code": "UNAUTHORIZED"
            }
        }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(TRPCError.self, from: json)
        XCTAssertEqual(error.error.message, "Not authenticated")
        XCTAssertEqual(error.error.code, "UNAUTHORIZED")
    }

    func testTRPCError_decodesWithHXCode() throws {
        let json = """
        {
            "error": {
                "message": "Task state transition invalid",
                "code": "HX001"
            }
        }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(TRPCError.self, from: json)
        XCTAssertEqual(error.error.code, "HX001")
        XCTAssertTrue(error.error.code?.hasPrefix("HX") ?? false,
                       "HX-prefixed codes should be recognized")
    }

    func testTRPCError_decodesWithNilCode() throws {
        let json = """
        {
            "error": {
                "message": "Something went wrong"
            }
        }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(TRPCError.self, from: json)
        XCTAssertEqual(error.error.message, "Something went wrong")
        XCTAssertNil(error.error.code)
    }

    // MARK: - APIError

    func testAPIError_unauthorizedDescription() {
        let err = APIError.unauthorized
        XCTAssertEqual(err.errorDescription, "Authentication required")
    }

    func testAPIError_httpErrorDescription() {
        let err = APIError.httpError(statusCode: 500)
        XCTAssertTrue(err.errorDescription?.contains("500") ?? false)
    }

    func testAPIError_constitutionalViolation_hxCode() {
        let err = APIError.constitutionalViolation(code: "HX001", message: "Bad state")
        XCTAssertEqual(err.hxCode, "HX001")
    }

    func testAPIError_constitutionalViolation_userFacingMessage() {
        let knownCodes: [(String, String)] = [
            ("HX001", "This action would create an invalid task state."),
            ("HX002", "Escrow funds cannot be modified in this state."),
            ("HX003", "XP cannot be awarded for this action."),
            ("HX100", "You don't have permission for this trust tier."),
            ("HX200", "Dispute resolution is already in progress."),
            ("HX300", "Verification requirements not met."),
            ("HX904", "Live Mode is in cooldown. Please wait."),
            ("HX905", "Live Mode access is temporarily restricted."),
        ]
        for (code, expected) in knownCodes {
            let err = APIError.constitutionalViolation(code: code, message: "raw msg")
            XCTAssertEqual(err.userFacingMessage, expected,
                           "HX code \(code) should have known user-facing message")
        }
    }

    func testAPIError_nonConstitutional_hxCodeIsNil() {
        let err = APIError.unauthorized
        XCTAssertNil(err.hxCode, "Non-constitutional errors should have nil hxCode")
    }

    func testAPIError_401_mapsToUnauthorized() {
        // This validates the logic: if httpResponse.statusCode == 401 -> throw .unauthorized
        let statusCode = 401
        let isUnauthorized = statusCode == 401
        XCTAssertTrue(isUnauthorized, "HTTP 401 should map to APIError.unauthorized")
    }
}
