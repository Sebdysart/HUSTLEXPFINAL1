//
//  ProofSubmissionScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Completion is within reach
//
//  v1.8.0: Enhanced with GPS capture and biometric validation feedback
//

import SwiftUI
import CoreLocation

struct ProofSubmissionScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    // v2.2.0: Real API services
    @StateObject private var proofService = ProofService.shared
    @StateObject private var taskService = TaskService.shared
    
    let taskId: String
    
    // Form state
    @State private var notes: String = ""
    @State private var hasPhoto: Bool = false
    @State private var capturedImage: UIImage?
    @State private var isSubmitting: Bool = false
    @State private var showCamera: Bool = false
    @State private var uploadedPhotoUrls: [String] = []
    
    // GPS state (v1.8.0)
    @State private var gpsCoordinates: GPSCoordinates?
    @State private var isCapturingGPS: Bool = false
    @State private var gpsError: String?
    
    // Validation state (v1.8.0)
    @State private var validationResult: BiometricValidationResult?
    @State private var showValidationFeedback: Bool = false
    
    // Flow state
    @State private var showSuccess: Bool = false
    @State private var currentStep: ProofStep = .gps
    
    private var task: HXTask? {
        dataService.activeTask
    }
    
    private var canProceedToPhoto: Bool {
        gpsCoordinates != nil
    }
    
    private var canSubmit: Bool {
        hasPhoto && gpsCoordinates != nil
    }
    
    var body: some View {
        if showSuccess {
            submissionSuccessView
        } else if showValidationFeedback, let result = validationResult {
            validationResultView(result)
        } else {
            submissionFormView
        }
    }
    
    // MARK: - Proof Steps
    
    private enum ProofStep {
        case gps
        case photo
        case review
    }
    
    // MARK: - Submission Form
    
    private var submissionFormView: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Step indicator
                    stepIndicator
                    
                    // Task summary
                    if let task = task {
                        taskSummaryCard(task)
                    }
                    
                    // GPS capture (v1.8.0)
                    gpsSection
                    
                    // Photo upload (only shown after GPS)
                    if canProceedToPhoto {
                        photoUploadSection
                    }
                    
                    // Notes (only shown after photo)
                    if hasPhoto {
                        notesSection
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding()
            }
        }
        .navigationTitle("Submit Proof")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HXText("Submit Proof", style: .title2)
            HXText("Capture your location and photo to verify completion", style: .subheadline, color: .textSecondary)
        }
    }
    
    // MARK: - Step Indicator
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            stepBadge(number: 1, label: "GPS", isActive: currentStep == .gps, isComplete: gpsCoordinates != nil)
            
            stepConnector(isComplete: gpsCoordinates != nil)
            
            stepBadge(number: 2, label: "Photo", isActive: currentStep == .photo, isComplete: hasPhoto)
            
            stepConnector(isComplete: hasPhoto)
            
            stepBadge(number: 3, label: "Submit", isActive: currentStep == .review, isComplete: false)
        }
        .padding(.vertical, 8)
    }
    
    private func stepBadge(number: Int, label: String, isActive: Bool, isComplete: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isComplete ? Color.successGreen : (isActive ? Color.brandPurple : Color.surfaceSecondary))
                    .frame(width: 32, height: 32)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isActive ? .white : Color.textSecondary)
                }
            }
            
            HXText(label, style: .caption, color: isActive || isComplete ? .textPrimary : .textSecondary)
        }
    }
    
    private func stepConnector(isComplete: Bool) -> some View {
        Rectangle()
            .fill(isComplete ? Color.successGreen : Color.surfaceSecondary)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
    
    // MARK: - Task Summary Card
    
    private func taskSummaryCard(_ task: HXTask) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HXText(task.title, style: .headline)
                HXText(task.location, style: .caption, color: .textSecondary)
            }
            
            Spacer()
            
            PriceDisplay(amount: task.payment, size: .small)
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
    
    // MARK: - GPS Section (v1.8.0)
    
    private var gpsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Location Capture", style: .headline)
                Spacer()
                if gpsCoordinates != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.successGreen)
                }
            }
            
            HXText("We'll capture your GPS coordinates to verify you're at the task location", style: .caption, color: .textSecondary)
            
            if let coords = gpsCoordinates {
                // GPS captured successfully
                gpsCapturedCard(coords)
            } else if let error = gpsError {
                // GPS error
                gpsErrorCard(error)
            } else {
                // GPS capture button
                gpsCaptureButton
            }
        }
    }
    
    private var gpsCaptureButton: some View {
        Button(action: captureGPS) {
            HStack(spacing: 12) {
                if isCapturingGPS {
                    ProgressView()
                        .tint(Color.brandPurple)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundStyle(Color.brandPurple)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText(isCapturingGPS ? "Capturing location..." : "Capture GPS Location", style: .subheadline)
                    HXText("Tap to record your current position", style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                if !isCapturingGPS {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding()
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isCapturingGPS)
    }
    
    private func gpsCapturedCard(_ coords: GPSCoordinates) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.successGreen)
                
                HXText("Location Captured", style: .subheadline)
                
                Spacer()
                
                Button(action: { gpsCoordinates = nil }) {
                    HXText("Recapture", style: .caption, color: .brandPurple)
                }
            }
            
            HStack(spacing: 16) {
                // Coordinates
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Coordinates", style: .caption, color: .textSecondary)
                    HXText(String(format: "%.4f, %.4f", coords.latitude, coords.longitude), style: .footnote)
                }
                
                Spacer()
                
                // Accuracy
                VStack(alignment: .trailing, spacing: 2) {
                    HXText("Accuracy", style: .caption, color: .textSecondary)
                    HStack(spacing: 4) {
                        accuracyIndicator(for: coords.accuracyMeters)
                        HXText(String(format: "±%.0fm", coords.accuracyMeters), style: .footnote)
                    }
                }
            }
            
            // Timestamp
            HStack {
                HXText("Captured", style: .caption, color: .textSecondary)
                Spacer()
                HXText(coords.timestamp.formatted(date: .omitted, time: .shortened), style: .caption, color: .textSecondary)
            }
        }
        .padding()
        .background(Color.successGreen.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.successGreen.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private func accuracyIndicator(for accuracy: Double) -> some View {
        let color: Color = {
            switch accuracy {
            case 0..<10: return .successGreen
            case 10..<30: return .warningOrange
            default: return .errorRed
            }
        }()
        
        return Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
    
    private func gpsErrorCard(_ error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.warningOrange)
                
                HXText("Location Error", style: .subheadline)
            }
            
            HXText(error, style: .caption, color: .textSecondary)
            
            HXButton("Try Again", variant: .secondary, size: .small) {
                gpsError = nil
                captureGPS()
            }
        }
        .padding()
        .background(Color.warningOrange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Photo Upload Section
    
    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Photo Proof", style: .headline)
                Spacer()
                if hasPhoto {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.successGreen)
                }
            }
            HXText("Take a photo showing your completed work", style: .caption, color: .textSecondary)
            
            Button(action: { 
                // Simulate photo capture
                withAnimation {
                    hasPhoto = true
                    currentStep = .review
                }
            }) {
                if hasPhoto {
                    // Photo preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceSecondary)
                            .aspectRatio(4/3, contentMode: .fit)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.successGreen)
                            
                            HXText("Photo added", style: .subheadline, color: .textSecondary)
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        Button(action: { 
                            hasPhoto = false
                            currentStep = .photo
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white, Color.errorRed)
                        }
                        .padding(8)
                    }
                } else {
                    // Upload prompt
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.brandPurple.opacity(0.1))
                                .frame(width: 64, height: 64)
                            
                            HXIcon(HXIcon.camera, size: .large, color: .brandPurple)
                        }
                        
                        HXText("Tap to add photo", style: .subheadline, color: .textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4/3, contentMode: .fit)
                    .background(Color.surfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(Color.brandPurple.opacity(0.3))
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            if currentStep == .gps && canProceedToPhoto {
                currentStep = .photo
            }
        }
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Notes (Optional)", style: .headline)
            
            TextField("Add any notes about the completed task", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color.surfaceElevated)
                .cornerRadius(12)
                .foregroundStyle(Color.textPrimary)
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 8) {
            if !canProceedToPhoto {
                HXButton("Capture GPS to Continue", variant: .secondary) {
                    captureGPS()
                }
                .disabled(isCapturingGPS)
                
                HXText("GPS location is required for verification", style: .caption, color: .textSecondary)
            } else {
                HXButton(
                    isSubmitting ? "Submitting..." : "Submit for Review",
                    variant: canSubmit ? .primary : .secondary,
                    isLoading: isSubmitting
                ) {
                    submitProof()
                }
                .disabled(!canSubmit || isSubmitting)
                
                if !hasPhoto {
                    HXText("Add a photo to submit", style: .caption, color: .textSecondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Validation Result View (v1.8.0)
    
    private func validationResultView(_ result: BiometricValidationResult) -> some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header based on result
                    validationHeader(result)
                    
                    // Validation scores section
                    validationScoresSection(result)
                        .padding(.horizontal)
                    
                    // Action based on result
                    validationActions(result)
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Validation Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func validationHeader(_ result: BiometricValidationResult) -> some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(headerColor(for: result.recommendation).opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: headerIcon(for: result.recommendation))
                    .font(.system(size: 40))
                    .foregroundStyle(headerColor(for: result.recommendation))
            }
            
            // Title
            VStack(spacing: 4) {
                HXText(headerTitle(for: result.recommendation), style: .title2)
                HXText(headerSubtitle(for: result.recommendation), style: .body, color: .textSecondary, alignment: .center)
            }
            .padding(.horizontal)
        }
    }
    
    private func headerColor(for recommendation: ValidationRecommendation) -> Color {
        switch recommendation {
        case .approve: return .successGreen
        case .manualReview: return .warningOrange
        case .reject: return .errorRed
        }
    }
    
    private func headerIcon(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "checkmark.shield.fill"
        case .manualReview: return "eye.fill"
        case .reject: return "xmark.shield.fill"
        }
    }
    
    private func headerTitle(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "Proof Validated"
        case .manualReview: return "Manual Review Required"
        case .reject: return "Validation Failed"
        }
    }
    
    private func headerSubtitle(for recommendation: ValidationRecommendation) -> String {
        switch recommendation {
        case .approve: return "Your proof has been automatically verified"
        case .manualReview: return "The poster will review your submission"
        case .reject: return "Please try submitting again"
        }
    }
    
    private func validationScoresSection(_ result: BiometricValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Reasoning
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.textMuted)
                
                Text(result.reasoning)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
            
            // Flags (if any)
            if !result.flags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HXText("Flags", style: .caption, color: .textMuted)
                    
                    HStack(spacing: 8) {
                        ForEach(result.flags, id: \.self) { flag in
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                
                                Text(flag.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(Color.warningOrange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.warningOrange.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Scores
            VStack(alignment: .leading, spacing: 12) {
                HXText("Validation Scores", style: .caption, color: .textMuted)
                
                VStack(spacing: 10) {
                    scoreBar(label: "Liveness", value: result.scores.liveness)
                    scoreBar(label: "Authenticity", value: 100 - result.scores.deepfake)
                    scoreBar(label: "GPS Proximity", value: result.scores.gpsProximity)
                }
            }
            
            // Risk badge
            HStack {
                Spacer()
                RiskBadge(level: result.riskLevel)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
        )
    }
    
    private func scoreBar(label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("\(value)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(scoreColor(for: value))
                    
                    if value >= 70 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.successGreen)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.surfaceSecondary)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(scoreColor(for: value))
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 6)
        }
    }
    
    private func scoreColor(for value: Int) -> Color {
        if value >= 80 { return .successGreen }
        if value >= 60 { return .warningOrange }
        return .errorRed
    }
    
    private func validationActions(_ result: BiometricValidationResult) -> some View {
        VStack(spacing: 12) {
            switch result.recommendation {
            case .approve, .manualReview:
                HXButton("Continue to Success") {
                    withAnimation(.spring(response: 0.4)) {
                        showValidationFeedback = false
                        showSuccess = true
                    }
                }
                
            case .reject:
                HXButton("Try Again") {
                    resetSubmission()
                }
                
                HXButton("Submit Anyway", variant: .secondary) {
                    withAnimation(.spring(response: 0.4)) {
                        showValidationFeedback = false
                        showSuccess = true
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Success View
    
    private var submissionSuccessView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                HXText("Proof Submitted!", style: .title)
                HXText("The poster will review your work", style: .body, color: .textSecondary, alignment: .center)
            }
            
            // Earnings preview
            if let task = task {
                VStack(spacing: 4) {
                    HXText("You'll earn", style: .subheadline, color: .textSecondary)
                    PriceDisplay(amount: task.payment, size: .large, color: .successGreen)
                }
                .padding()
                .background(Color.successGreen.opacity(0.1))
                .cornerRadius(12)
            }
            
            // GPS verification badge
            if let coords = gpsCoordinates {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.successGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HXText("Location Verified", style: .caption)
                        HXText(String(format: "%.4f, %.4f", coords.latitude, coords.longitude), style: .caption, color: .textSecondary)
                    }
                }
                .padding()
                .background(Color.surfaceElevated)
                .cornerRadius(8)
            }
            
            Spacer()
            
            HXButton("Back to Home") {
                // Reset navigation and complete task
                if let task = task {
                    dataService.updateTaskState(task.id, to: .proofSubmitted)
                }
                router.hustlerPath = NavigationPath()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Actions
    
    private func captureGPS() {
        isCapturingGPS = true
        gpsError = nil
        currentStep = .gps
        
        print("[ProofSubmission] Capturing GPS coordinates...")
        
        // Use mock location service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let mockService = MockLocationService.shared
            let result = mockService.getCurrentLocation()
            
            switch result {
            case .success(let coords):
                withAnimation {
                    gpsCoordinates = coords
                    isCapturingGPS = false
                    currentStep = .photo
                }
                print("[ProofSubmission] GPS captured: \(coords.latitude), \(coords.longitude)")
                
            case .failure(let error):
                gpsError = error.localizedDescription
                isCapturingGPS = false
                print("[ProofSubmission] GPS error: \(error.localizedDescription)")
            }
        }
    }
    
    private func submitProof() {
        guard hasPhoto, let coords = gpsCoordinates else { return }
        
        isSubmitting = true
        print("[ProofSubmission] Submitting proof for task: \(taskId)")
        print("[ProofSubmission] GPS: \(coords.latitude), \(coords.longitude)")
        
        // v2.2.0: Use real API to submit proof
        Task {
            do {
                // Upload photo if we have one
                var photoUrls: [String] = uploadedPhotoUrls
                if let image = capturedImage, photoUrls.isEmpty {
                    print("[ProofSubmission] Uploading photo to R2...")
                    let url = try await proofService.uploadProofPhoto(
                        image: image,
                        taskId: taskId,
                        photoIndex: 0
                    )
                    photoUrls = [url]
                    uploadedPhotoUrls = photoUrls
                    print("[ProofSubmission] Photo uploaded: \(url)")
                }
                
                // Generate biometric hash
                let biometricHash = BiometricProofGenerator.generateHash(
                    latitude: coords.latitude,
                    longitude: coords.longitude
                )
                
                // Submit proof via API
                _ = try await proofService.submitProof(
                    taskId: taskId,
                    photoUrls: photoUrls.isEmpty ? ["mock://proof-photo.jpg"] : photoUrls,
                    notes: notes.isEmpty ? nil : notes,
                    gpsLatitude: coords.latitude,
                    gpsLongitude: coords.longitude,
                    biometricHash: biometricHash
                )
                
                print("✅ ProofSubmission: Proof submitted via API")
                
                // Also submit via TaskService to update task state
                _ = try await taskService.submitProof(
                    taskId: taskId,
                    photoUrls: photoUrls.isEmpty ? ["mock://proof-photo.jpg"] : photoUrls,
                    notes: notes.isEmpty ? nil : notes,
                    gpsLatitude: coords.latitude,
                    gpsLongitude: coords.longitude,
                    biometricHash: biometricHash
                )
                
                // Create biometric proof submission for local validation
                let photoURL: URL? = photoUrls.first.flatMap { URL(string: $0) }
                let submission = BiometricProofSubmission(
                    proofId: UUID().uuidString,
                    photoURL: photoURL,
                    gpsCoordinates: coords,
                    gpsAccuracyMeters: coords.accuracyMeters,
                    gpsTimestamp: coords.timestamp,
                    deviceModel: "iPhone16,3",
                    osVersion: "18.0"
                )
                
                // Get validation result from mock service (for UI feedback)
                let result = dataService.validateBiometricProof(
                    submission: submission,
                    taskId: taskId
                )
                
                isSubmitting = false
                validationResult = result
                
                withAnimation(.spring(response: 0.4)) {
                    showValidationFeedback = true
                }
                
                print("[ProofSubmission] Validation result: \(result.recommendation.rawValue)")
                
            } catch {
                print("⚠️ ProofSubmission: API failed - \(error.localizedDescription)")
                
                // Fall back to mock validation
                let photoURL: URL? = uploadedPhotoUrls.first.flatMap { URL(string: $0) }
                let submission = BiometricProofSubmission(
                    proofId: UUID().uuidString,
                    photoURL: photoURL,
                    gpsCoordinates: coords,
                    gpsAccuracyMeters: coords.accuracyMeters,
                    gpsTimestamp: coords.timestamp,
                    deviceModel: "iPhone16,3",
                    osVersion: "18.0"
                )
                
                let result = dataService.validateBiometricProof(
                    submission: submission,
                    taskId: taskId
                )
                
                isSubmitting = false
                validationResult = result
                
                withAnimation(.spring(response: 0.4)) {
                    showValidationFeedback = true
                }
            }
        }
    }
    
    private func resetSubmission() {
        withAnimation {
            showValidationFeedback = false
            validationResult = nil
            hasPhoto = false
            gpsCoordinates = nil
            notes = ""
            currentStep = .gps
        }
    }
}

#Preview {
    NavigationStack {
        ProofSubmissionScreen(taskId: "task-001")
    }
    .environment(AppState())
    .environment(Router())
    .environment(MockDataService.shared)
}
