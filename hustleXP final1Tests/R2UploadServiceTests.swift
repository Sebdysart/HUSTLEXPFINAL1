import XCTest
import UIKit
@testable import hustleXP_final1

@MainActor
final class R2UploadServiceTests: XCTestCase {

    var sut: R2UploadService!
    var mockClient: MockTRPCClient!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        sut = R2UploadService(client: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - Shared Instance

    func testSharedInstance_exists() {
        XCTAssertNotNil(R2UploadService.shared)
    }

    // MARK: - Initial State

    func testInitialState_notUploading() {
        XCTAssertFalse(sut.isUploading)
        XCTAssertEqual(sut.uploadProgress, 0.0)
    }

    // MARK: - Upload Error Path

    func testUploadPhoto_withNetworkError_throwsR2UploadError() async {
        mockClient.stubError("upload.getPresignedUrl", error: MockNetworkError.serverError)

        // Create a 1x1 test image
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let testImage = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        do {
            _ = try await sut.uploadPhoto(testImage, purpose: .proof, taskId: "task-1")
            XCTFail("Expected error to be thrown")
        } catch {
            // Should get a presignedUrlFailed wrapping our mock error
            XCTAssertTrue(error is R2UploadError,
                          "Expected R2UploadError but got \(type(of: error))")
        }
    }
}
