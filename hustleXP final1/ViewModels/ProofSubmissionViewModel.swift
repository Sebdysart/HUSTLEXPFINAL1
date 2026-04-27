//
//  ProofSubmissionViewModel.swift
//  hustleXP final1
//
//  Extracted from ProofSubmissionScreen.swift
//  Archetype: C (Task Lifecycle)
//
//  Contains all business logic, API calls, and state management
//  for proof submission flow.
//

import SwiftUI
import CoreLocation
import PhotosUI

// MARK: - ProofSubmissionViewModel

@Observable
@MainActor
final class ProofSubmissionViewModel {

    // MARK: - Dependencies (injected after init)

    /// Set these after init so the ViewModel can talk to environment objects.
    var dataService: LiveDataService?
    var router: Router?

    // MARK: - Services

    let proofService = ProofService.shared
    let taskService = TaskService.shared
    let locationManager = RealLocationManager()

    // MARK: - Inputs

    let taskId: String

    // MARK: - Form State

    var notes: String = ""
    var hasPhoto: Bool = false
    var capturedImage: UIImage?
    var isSubmitting: Bool = false
    var showCamera: Bool = false
    var cameraUnavailable: Bool = false
    var showPhotoPicker: Bool = false
    var selectedPhotoItem: PhotosPickerItem?
    var uploadedPhotoUrls: [String] = []

    // MARK: - GPS State (v1.8.0)

    var gpsCoordinates: GPSCoordinates?
    var isCapturingGPS: Bool = false
    var gpsError: String?

    // MARK: - Validation State (v1.8.0)

    var validationResult: BiometricValidationResult?
    var showValidationFeedback: Bool = false

    // MARK: - Flow State

    var showSuccess: Bool = false
    var currentStep: ProofStep = .gps

    // MARK: - Init

    init(taskId: String) {
        self.taskId = taskId
    }

    // MARK: - Proof Steps

    enum ProofStep {
        case gps
        case photo
        case review
    }

    // MARK: - Computed Properties

    var task: HXTask? {
        dataService?.activeTask
    }

    var canProceedToPhoto: Bool {
        gpsCoordinates != nil
    }

    var canSubmit: Bool {
        hasPhoto && gpsCoordinates != nil
    }

    /// Converts the captured UIImage to a local file URL string for proof submission
    var localProofPhotoURL: String {
        guard let image = capturedImage,
              let data = image.jpegData(compressionQuality: 0.8) else {
            return "file://proof-pending-upload"
        }
        let filename = "proof_\(taskId)_\(Int(Date().timeIntervalSince1970)).jpg"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: tempURL)
        return tempURL.absoluteString
    }

    // MARK: - Validation Header Helpers

    func headerColor(for recommendation: ValidationRecommendation) -> Color {
        switch recommendation {
        case .approve: return .successGreen
        case .manualReview: return .warningOrange
        case .reject: return .errorRed
        }
    }

    func headerIcon(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "checkmark.shield.fill"
        case .manualReview: return "eye.fill"
        case .reject: return "xmark.shield.fill"
        }
    }

    func headerTitle(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "Proof Validated"
        case .manualReview: return "Manual Review Required"
        case .reject: return "Validation Failed"
        }
    }

    func headerSubtitle(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "Your proof has been automatically verified"
        case .manualReview: return "The poster will review your submission"
        case .reject: return "Please try submitting again"
        }
    }

    func scoreColor(for value: Int) -> Color {
        if value >= 80 { return .successGreen }
        if value >= 60 { return .warningOrange }
        return .errorRed
    }

    // MARK: - Actions

    func captureGPS() {
        isCapturingGPS = true
        gpsError = nil
        currentStep = .gps

        HXLogger.debug("[ProofSubmission] Capturing GPS coordinates...", category: "Task")

        locationManager.requestLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let location):
                let coords = GPSCoordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    accuracyMeters: location.horizontalAccuracy,
                    timestamp: location.timestamp
                )
                withAnimation {
                    self.gpsCoordinates = coords
                    self.isCapturingGPS = false
                    self.currentStep = .photo
                }
                HXLogger.debug("[ProofSubmission] GPS captured: \(coords.latitude), \(coords.longitude) (+-\(Int(coords.accuracyMeters))m)", category: "Task")

            case .failure(let error):
                self.gpsError = error.localizedDescription
                self.isCapturingGPS = false
                HXLogger.debug("[ProofSubmission] GPS error: \(error.localizedDescription)", category: "Task")
            }
        }
    }

    func clearGPS() {
        gpsCoordinates = nil
    }

    func retryGPS() {
        gpsError = nil
        captureGPS()
    }

    func removePhoto() {
        hasPhoto = false
        capturedImage = nil
        currentStep = .photo
    }

    func handlePhotoPickerSelection(_ newItem: PhotosPickerItem?) async {
        if let newItem,
           let data = try? await newItem.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            capturedImage = image
            hasPhoto = true
            currentStep = .review
        }
    }

    func handleCameraDisappeared() {
        if capturedImage != nil {
            hasPhoto = true
            currentStep = .review
        }
    }

    func updateStepIfNeeded() {
        if currentStep == .gps && canProceedToPhoto {
            currentStep = .photo
        }
    }

    func submitProof() {
        guard hasPhoto, let coords = gpsCoordinates else { return }
        guard dataService != nil else { return }

        isSubmitting = true
        HXLogger.debug("[ProofSubmission] Submitting proof for task: \(taskId)", category: "Task")

        Task {
            // ── Step 1: Upload photo ──
            var photoUrls: [String] = uploadedPhotoUrls
            if let image = capturedImage, photoUrls.isEmpty {
                do {
                    HXLogger.debug("[ProofSubmission] Uploading photo to R2...", category: "Task")
                    let url = try await proofService.uploadProofPhoto(
                        image: image,
                        taskId: taskId,
                        photoIndex: 0
                    )
                    photoUrls = [url]
                    uploadedPhotoUrls = photoUrls
                } catch {
                    HXLogger.error("ProofSubmission: Photo upload failed - \(error.localizedDescription)", category: "Task")
                    isSubmitting = false
                    ErrorToastManager.shared.show("Photo upload failed. Please try again.")
                    return
                }
            }

            // ── Step 2: Submit proof to backend ──
            let biometricHash = BiometricProofGenerator.generateHash(
                latitude: coords.latitude,
                longitude: coords.longitude
            )

            do {
                let proofResult = try await proofService.submitProof(
                    taskId: taskId,
                    photoUrls: photoUrls.isEmpty ? [localProofPhotoURL] : photoUrls,
                    notes: notes.isEmpty ? nil : notes,
                    gpsLatitude: coords.latitude,
                    gpsLongitude: coords.longitude,
                    biometricHash: biometricHash
                )
                HXLogger.info("ProofSubmission: Proof submitted - proofId: \(proofResult.id)", category: "Task")
            } catch {
                HXLogger.error("ProofSubmission: Proof submission failed - \(error.localizedDescription)", category: "Task")
                isSubmitting = false
                ErrorToastManager.shared.show("Failed to submit proof: \(error.localizedDescription)")
                return
            }

            // Step 3: Biometric validation skipped for beta.
            // Poster reviews proof manually. Re-enable when BIPA consent flow is built.
            isSubmitting = false
            validationResult = BiometricValidationResult(
                recommendation: .manualReview,
                reasoning: "Your proof has been submitted. The poster will review it shortly.",
                flags: [],
                scores: ValidationScores(liveness: 0, deepfake: 0, gpsProximity: 0),
                riskLevel: .low
            )

            withAnimation(.spring(response: 0.4)) {
                showValidationFeedback = true
            }
        }
    }

    func resetSubmission() {
        withAnimation {
            showValidationFeedback = false
            validationResult = nil
            hasPhoto = false
            gpsCoordinates = nil
            notes = ""
            currentStep = .gps
        }
    }

    func continueToSuccess() {
        withAnimation(.spring(response: 0.4)) {
            showValidationFeedback = false
            showSuccess = true
        }
    }

    func completeAndGoHome() {
        guard let dataService, let router else { return }

        // Update local state immediately so UI reflects the change
        if let task = task {
            var updated = task
            updated.state = .proofSubmitted
            dataService.activeTask = updated
        }

        // Navigate home
        router.hustlerPath = NavigationPath()

        // Refresh from backend so all screens get fresh data
        Task {
            await dataService.refreshAll()
        }
    }
}
