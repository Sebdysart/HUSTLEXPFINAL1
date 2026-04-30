//
//  ProofSubmissionScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Completion is within reach
//
//  v1.8.0: Enhanced with GPS capture and biometric validation feedback
//  v3.0.0: Refactored — logic extracted to ProofSubmissionViewModel
//

import SwiftUI
import CoreLocation
import PhotosUI
import Combine

struct ProofSubmissionScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    let taskId: String

    @State private var viewModel: ProofSubmissionViewModel
    @State private var showRatingSheet = false

    init(taskId: String) {
        self.taskId = taskId
        _viewModel = State(initialValue: ProofSubmissionViewModel(taskId: taskId))
    }

    var body: some View {
        if viewModel.showSuccess {
            submissionSuccessView
        } else if viewModel.showValidationFeedback, let result = viewModel.validationResult {
            validationResultView(result)
        } else {
            submissionFormView
        }
    }

    // MARK: - Submission Form

    private var submissionFormView: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: isCompact ? 18 : 24) {
                        headerSection(isCompact: isCompact)
                        stepIndicator(isCompact: isCompact)

                        if let task = viewModel.task {
                            taskSummaryCard(task, isCompact: isCompact)
                        }

                        gpsSection(isCompact: isCompact)

                        if viewModel.canProceedToPhoto {
                            photoUploadSection(isCompact: isCompact)
                        }

                        if viewModel.hasPhoto {
                            notesSection(isCompact: isCompact)
                        }

                        Spacer(minLength: isCompact ? 100 : 120)
                    }
                    .padding(isCompact ? 16 : 20)
                }
            }
            .navigationTitle("Submit Proof")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            // Hide the tab bar — submit flow is a focused workflow,
            // and the Submit button needs to sit at the very bottom edge.
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                bottomBar(bottomSafeArea: geometry.safeAreaInsets.bottom)
            }
        }
        .onAppear {
            viewModel.dataService = dataService
            viewModel.router = router
        }
    }

    // MARK: - Header Section

    private func headerSection(isCompact: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Hero icon with glow
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .blur(radius: 8)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Submit Proof")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Text("Verify completion to release payment")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }

    // MARK: - Step Indicator

    private func stepIndicator(isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 6 : 8) {
            stepBadge(number: 1, label: "GPS", isActive: viewModel.currentStep == .gps, isComplete: viewModel.gpsCoordinates != nil, isCompact: isCompact)
            stepConnector(isComplete: viewModel.gpsCoordinates != nil)
            stepBadge(number: 2, label: "Photo", isActive: viewModel.currentStep == .photo, isComplete: viewModel.hasPhoto, isCompact: isCompact)
            stepConnector(isComplete: viewModel.hasPhoto)
            stepBadge(number: 3, label: "Submit", isActive: viewModel.currentStep == .review, isComplete: false, isCompact: isCompact)
        }
        .padding(.vertical, isCompact ? 6 : 8)
    }

    private func stepBadge(number: Int, label: String, isActive: Bool, isComplete: Bool, isCompact: Bool = false) -> some View {
        VStack(spacing: isCompact ? 3 : 4) {
            ZStack {
                Circle()
                    .fill(isComplete ? Color.successGreen : (isActive ? Color.brandPurple : Color.surfaceSecondary))
                    .frame(width: isCompact ? 28 : 32, height: isCompact ? 28 : 32)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: isCompact ? 12 : 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
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

    private func taskSummaryCard(_ task: HXTask, isCompact: Bool) -> some View {
        HStack(spacing: 14) {
            // Briefcase icon chip
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandPurple.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textTertiary)
                    Text(task.location)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Int(task.payment))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moneyGreen)
                Text("PAYOUT")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple.opacity(0.05), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
        )
    }

    // MARK: - GPS Section (v1.8.0)

    private func gpsSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("STEP 1 · LOCATION", icon: "location.fill", isComplete: viewModel.gpsCoordinates != nil)

            if let coords = viewModel.gpsCoordinates {
                gpsCapturedCard(coords)
            } else if let error = viewModel.gpsError {
                gpsErrorCard(error)
            } else {
                gpsCaptureButton
            }
        }
    }

    /// Reusable section label with completion indicator.
    private func sectionLabel(_ text: String, icon: String, isComplete: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isComplete ? Color.successGreen : Color.brandPurple)
            Text(text)
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(isComplete ? Color.successGreen : Color.brandPurple)

            Spacer()

            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.successGreen)
            }
        }
    }

    private var gpsCaptureButton: some View {
        Button(action: { viewModel.captureGPS() }) {
            HStack(spacing: 12) {
                if viewModel.isCapturingGPS {
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
                    HXText(viewModel.isCapturingGPS ? "Capturing location..." : "Capture GPS Location", style: .subheadline)
                    HXText("Tap to record your current position", style: .caption, color: .textSecondary)
                }

                Spacer()

                if !viewModel.isCapturingGPS {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding()
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isCapturingGPS)
        .accessibilityLabel("Capture GPS location")
    }

    private func gpsCapturedCard(_ coords: GPSCoordinates) -> some View {
        VStack(spacing: 14) {
            // Header row with status pill
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.successGreen.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.successGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Location Captured")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Verified at task location")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button(action: { viewModel.clearGPS() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .bold))
                        Text("Recapture")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.brandPurple.opacity(0.15)))
                }
            }

            Divider().background(Color.successGreen.opacity(0.2))

            // Stats grid
            HStack(spacing: 0) {
                // Coordinates
                VStack(alignment: .leading, spacing: 4) {
                    Text("COORDINATES")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(Color.textTertiary)
                    Text(String(format: "%.4f, %.4f", coords.latitude, coords.longitude))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Accuracy
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ACCURACY")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(Color.textTertiary)
                    HStack(spacing: 5) {
                        accuracyIndicator(for: coords.accuracyMeters)
                        Text(String(format: "±%.0fm", coords.accuracyMeters))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }

            // Timestamp footer
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text("Captured \(coords.timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 11))
                Spacer()
            }
            .foregroundStyle(Color.textTertiary)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.successGreen.opacity(0.08))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.successGreen.opacity(0.3), lineWidth: 1)
            }
        )
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
                viewModel.retryGPS()
            }
        }
        .padding()
        .background(Color.warningOrange.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Photo Upload Section

    private func photoUploadSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("STEP 2 · PHOTO PROOF", icon: "camera.fill", isComplete: viewModel.hasPhoto)

            if viewModel.hasPhoto, let image = viewModel.capturedImage {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width * 3 / 4)
                        .clipped()
                        .cornerRadius(12)
                }
                .aspectRatio(4/3, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    Button(action: { viewModel.removePhoto() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, Color.errorRed)
                    }
                    .padding(8)
                }
            } else {
                VStack(spacing: 16) {
                    Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            viewModel.showCamera = true
                        } else {
                            viewModel.cameraUnavailable = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPurple.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.brandPurple)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HXText("Take Photo", style: .subheadline)
                                HXText("Use camera to capture proof", style: .caption, color: .textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding()
                        .background(Color.surfaceElevated)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Take photo for proof")

                    PhotosPicker(
                        selection: Binding(
                            get: { viewModel.selectedPhotoItem },
                            set: { viewModel.selectedPhotoItem = $0 }
                        ),
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.infoBlue.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.infoBlue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HXText("Choose from Library", style: .subheadline)
                                HXText("Select existing photo", style: .caption, color: .textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding()
                        .background(Color.surfaceElevated)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            viewModel.updateStepIfNeeded()
        }
        .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
            Task {
                await viewModel.handlePhotoPickerSelection(newItem)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.showCamera },
            set: { viewModel.showCamera = $0 }
        )) {
            CameraView(
                image: Binding(
                    get: { viewModel.capturedImage },
                    set: { viewModel.capturedImage = $0 }
                ),
                isPresented: Binding(
                    get: { viewModel.showCamera },
                    set: { viewModel.showCamera = $0 }
                )
            )
            .ignoresSafeArea()
            .onDisappear {
                viewModel.handleCameraDisappeared()
            }
        }
        .alert("Camera Unavailable", isPresented: Binding(
            get: { viewModel.cameraUnavailable },
            set: { viewModel.cameraUnavailable = $0 }
        )) {
            Button("Use Photo Library") { viewModel.showPhotoPicker = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Camera is not available on this device. Use the photo library instead.")
        }
    }

    // MARK: - Notes Section

    private func notesSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("STEP 3 · NOTES", icon: "text.bubble.fill", isComplete: !viewModel.notes.isEmpty)

            TextField("", text: Binding(
                get: { viewModel.notes },
                set: { viewModel.notes = $0 }
            ), prompt: Text("Add any notes about the completed task (optional)").foregroundColor(.textTertiary), axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(3...6)
                .padding(14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceElevated)
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    }
                )
                .foregroundStyle(Color.textPrimary)
        }
    }

    // MARK: - Bottom Bar

    private func bottomBar(bottomSafeArea: CGFloat = 0) -> some View {
        VStack(spacing: 10) {
            // Subtle gradient hairline divider — separates content from action bar
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.12), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.bottom, 4)

            if !viewModel.canProceedToPhoto {
                // Active primary CTA — same vibrant styling as other primary actions
                HXButton(
                    viewModel.isCapturingGPS ? "Capturing GPS..." : "Capture GPS to Continue",
                    variant: .primary,
                    isLoading: viewModel.isCapturingGPS
                ) {
                    viewModel.captureGPS()
                }
                .disabled(viewModel.isCapturingGPS)

                HXText("GPS location is required for verification", style: .caption, color: .textSecondary)
            } else {
                HXButton(
                    viewModel.isSubmitting ? "Submitting..." : "Submit for Review",
                    variant: .primary,
                    isLoading: viewModel.isSubmitting
                ) {
                    viewModel.submitProof()
                }
                .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
                .opacity(viewModel.canSubmit ? 1 : 0.5)

                if !viewModel.hasPhoto {
                    HXText("Add a photo to submit", style: .caption, color: .textSecondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        // Use system safe area inset only (no extra padding) — sits flush at bottom
        .padding(.bottom, max(20, bottomSafeArea))
        .background(Color.brandBlack)
    }

    // MARK: - Validation Result View (v1.8.0)

    private func validationResultView(_ result: BiometricValidationResult) -> some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    validationHeader(result)
                    validationScoresSection(result)
                        .padding(.horizontal)
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
            ZStack {
                Circle()
                    .fill(viewModel.headerColor(for: result.recommendation).opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: viewModel.headerIcon(for: result.recommendation))
                    .font(.system(size: 40))
                    .foregroundStyle(viewModel.headerColor(for: result.recommendation))
            }

            VStack(spacing: 4) {
                HXText(viewModel.headerTitle(for: result.recommendation), style: .title2)
                HXText(viewModel.headerSubtitle(for: result.recommendation), style: .body, color: .textSecondary, alignment: .center)
            }
            .padding(.horizontal)
        }
    }

    private func validationScoresSection(_ result: BiometricValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
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

            VStack(alignment: .leading, spacing: 12) {
                HXText("Validation Scores", style: .caption, color: .textMuted)

                VStack(spacing: 10) {
                    scoreBar(label: "Liveness", value: result.scores.liveness)
                    scoreBar(label: "Authenticity", value: 100 - result.scores.deepfake)
                    scoreBar(label: "GPS Proximity", value: result.scores.gpsProximity)
                }
            }

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
                        .foregroundStyle(viewModel.scoreColor(for: value))

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
                        .fill(viewModel.scoreColor(for: value))
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 6)
        }
    }

    private func validationActions(_ result: BiometricValidationResult) -> some View {
        VStack(spacing: 12) {
            switch result.recommendation {
            case .approve, .manualReview:
                HXButton("Continue to Success") {
                    viewModel.continueToSuccess()
                }

            case .reject:
                HXButton("Try Again") {
                    viewModel.resetSubmission()
                }

                HXButton("Submit Anyway", variant: .secondary) {
                    viewModel.continueToSuccess()
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Success View

    private var submissionSuccessView: some View {
        ZStack {
            // Dark background — extends edge to edge, including under nav bar
            Color.brandBlack.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Animated success icon with glow
                ZStack {
                    Circle()
                        .fill(Color.successGreen.opacity(0.18))
                        .frame(width: 140, height: 140)
                        .blur(radius: 24)

                    Circle()
                        .fill(Color.successGreen.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(Color.successGreen.opacity(0.4), lineWidth: 2)
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(Color.successGreen)
                        .shadow(color: Color.successGreen.opacity(0.6), radius: 8)
                }

                VStack(spacing: 8) {
                    Text("Proof Submitted!")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text("The poster will review your work shortly")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let task = viewModel.task {
                    VStack(spacing: 4) {
                        Text("YOU'LL EARN")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(Color.textSecondary)
                        Text("$\(String(format: "%.2f", task.payment))")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.successGreen)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.successGreen.opacity(0.12))
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.successGreen.opacity(0.3), lineWidth: 1)
                        }
                    )
                }

                if let coords = viewModel.gpsCoordinates {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.successGreen.opacity(0.2))
                                .frame(width: 30, height: 30)
                            Image(systemName: "location.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.successGreen)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Location Verified")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                            Text(String(format: "%.4f, %.4f", coords.latitude, coords.longitude))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.surfaceElevated)
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        }
                    )
                }

                // Rate the poster prompt
                if let task = viewModel.task {
                    Button {
                        showRatingSheet = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.warningOrange.opacity(0.18))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.warningOrange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rate \(task.posterName)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.textPrimary)
                                Text("How was your experience?")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(14)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.surfaceElevated)
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                            }
                        )
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                HXButton("Back to Home") {
                    viewModel.completeAndGoHome()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showRatingSheet) {
            if let task = viewModel.task {
                RateTaskSheet(
                    taskId: task.id,
                    taskTitle: task.title,
                    otherUserName: task.posterName,
                    isPresented: $showRatingSheet
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Real Location Manager

/// CoreLocation manager for real GPS capture
final class RealLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((Result<CLLocation, Error>) -> Void)?

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        self.completion = completion

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(.failure(LocationError.permissionDenied))
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            completion(.failure(LocationError.unknown))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if completion != nil {
                manager.requestLocation()
            }
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            completion?(.failure(LocationError.permissionDenied))
            completion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            completion?(.success(location))
            completion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(error))
        completion = nil
    }
}

// MARK: - Camera View (UIKit Bridge)

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    NavigationStack {
        ProofSubmissionScreen(taskId: "task-001")
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
