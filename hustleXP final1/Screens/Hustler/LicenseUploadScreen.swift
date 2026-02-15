//
//  LicenseUploadScreen.swift
//  hustleXP final1
//
//  License Upload & AI Verification Screen
//  - Document capture (mock)
//  - State database lookup (mock)
//  - Real-time verification status
//

import SwiftUI

struct LicenseUploadScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let licenseType: LicenseType
    
    @State private var licenseNumber: String = ""
    @State private var issuingState: String = ""
    @State private var hasUploadedDocument: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var verificationStatus: LicenseVerificationStatus? = nil
    @State private var showStateSelector: Bool = false
    @State private var showSuccess: Bool = false
    
    private let licenseService = MockLicenseVerificationService.shared
    
    private let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    private var isValid: Bool {
        !licenseNumber.isEmpty && !issuingState.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header
                    
                    // License type card
                    licenseTypeCard
                    
                    // Form fields
                    formSection
                    
                    // Document upload
                    documentUpload
                    
                    // Verification status
                    if let status = verificationStatus {
                        verificationStatusView(status)
                    }
                    
                    // Fee info
                    feeInfo
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom button
            VStack {
                Spacer()
                submitButton
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showStateSelector) {
            stateSelector
        }
        .sheet(isPresented: $showSuccess) {
            successSheet
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Text("License Verification")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - License Type Card
    
    private var licenseTypeCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.instantYellow.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: licenseType.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.instantYellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(licenseType.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                HStack(spacing: 6) {
                    Image(systemName: licenseType.stateRegulated ? "building.columns.fill" : "checkmark.shield")
                        .font(.system(size: 12))
                    Text(licenseType.stateRegulated ? "State Regulated" : "Certification")
                        .font(.system(size: 13))
                }
                .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // License number
            VStack(alignment: .leading, spacing: 8) {
                Text("License Number")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("Enter your license number", text: $licenseNumber)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textInputAutocapitalization(.characters)
            }
            
            // Issuing state
            VStack(alignment: .leading, spacing: 8) {
                Text("Issuing State")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                Button {
                    showStateSelector = true
                } label: {
                    HStack {
                        Text(issuingState.isEmpty ? "Select state" : issuingState)
                            .font(.system(size: 16))
                            .foregroundStyle(issuingState.isEmpty ? Color.textMuted : Color.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }
                    .padding(14)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Document Upload
    
    private var documentUpload: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("License Photo (Optional)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.textSecondary)
            
            Button {
                // Mock document upload
                withAnimation {
                    hasUploadedDocument = true
                }
            } label: {
                VStack(spacing: 12) {
                    if hasUploadedDocument {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.successGreen)
                        
                        Text("Document Uploaded")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.successGreen)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.textMuted)
                        
                        Text("Tap to upload license photo")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textSecondary)
                        
                        Text("Speeds up verification")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            hasUploadedDocument ? Color.successGreen : Color.borderSubtle,
                            style: StrokeStyle(lineWidth: 2, dash: hasUploadedDocument ? [] : [8])
                        )
                )
            }
        }
    }
    
    // MARK: - Verification Status
    
    private func verificationStatusView(_ status: LicenseVerificationStatus) -> some View {
        HStack(spacing: 12) {
            if status == .processing {
                ProgressView()
                    .tint(.warningOrange)
            } else {
                Image(systemName: status.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(status.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle(for: status))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(statusMessage(for: status))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(status.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func statusTitle(for status: LicenseVerificationStatus) -> String {
        switch status {
        case .pending: return "Submitted"
        case .processing: return "Verifying..."
        case .verified: return "Verified!"
        case .rejected: return "Verification Failed"
        case .expired: return "License Expired"
        case .manualReview: return "Under Review"
        }
    }
    
    private func statusMessage(for status: LicenseVerificationStatus) -> String {
        switch status {
        case .pending: return "Your license is in the queue"
        case .processing: return "Checking state database..."
        case .verified: return "You can now accept \(licenseType.rawValue) quests"
        case .rejected: return "Please check your license number"
        case .expired: return "Please upload a current license"
        case .manualReview: return "A human will review within 24 hours"
        }
    }
    
    // MARK: - Fee Info
    
    private var feeInfo: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.infoBlue)
                
                Text("Verification Details")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                feeRow(icon: "dollarsign.circle", text: "One-time fee: $\(String(format: "%.2f", licenseType.verificationFee))")
                feeRow(icon: "clock", text: "Usually verified in seconds")
                feeRow(icon: "shield.checkered", text: "Cross-referenced with state database")
                feeRow(icon: "repeat", text: "Re-verify when license expires")
            }
        }
        .padding(16)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func feeRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.textMuted)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            submitVerification()
        } label: {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Verify License - $\(String(format: "%.2f", licenseType.verificationFee))")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(isValid ? Color.brandBlack : Color.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Color.instantYellow : Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!isValid || isSubmitting || verificationStatus == .verified)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .background(
            LinearGradient(
                colors: [.brandBlack.opacity(0), .brandBlack],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - State Selector
    
    private var stateSelector: some View {
        NavigationView {
            List(usStates, id: \.self) { state in
                Button {
                    issuingState = state
                    showStateSelector = false
                } label: {
                    HStack {
                        Text(state)
                            .foregroundStyle(Color.textPrimary)
                        
                        Spacer()
                        
                        if issuingState == state {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.brandPurple)
                        }
                    }
                }
            }
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        showStateSelector = false
                    }
                }
            }
        }
    }
    
    // MARK: - Success Sheet
    
    private var successSheet: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Checkmark animation
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                Text("License Verified!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("You can now accept \(licenseType.rawValue) quests and earn premium rates.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("$\(String(format: "%.0f", Double.random(in: 75...150)))+")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.successGreen)
                    Text("Avg Quest")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textMuted)
                }
                
                VStack(spacing: 4) {
                    Text("\(Int.random(in: 5...15))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.infoBlue)
                    Text("Nearby")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            Button {
                showSuccess = false
                dismiss()
            } label: {
                Text("View \(licenseType.rawValue) Quests")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.brandBlack)
    }
    
    // MARK: - Actions
    
    private func submitVerification() {
        guard isValid else { return }
        
        isSubmitting = true
        verificationStatus = .pending
        
        // v2.2.0: Submit license via real API
        Task {
            do {
                _ = try await SkillService.shared.submitLicense(
                    skillId: licenseType.rawValue,
                    licenseType: licenseType.rawValue,
                    licenseNumber: licenseNumber,
                    photoUrl: "placeholder://license-upload"
                )
                print("✅ LicenseUpload: Submitted via API")
            } catch {
                print("⚠️ LicenseUpload: API failed - \(error.localizedDescription)")
            }
        }

        // Submit to mock service for status tracking
        _ = licenseService.uploadLicense(
            type: licenseType,
            licenseNumber: licenseNumber,
            issuingState: issuingState,
            documentURL: nil
        )
        
        // Poll for status updates
        Task {
            while verificationStatus != .verified && verificationStatus != .rejected {
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                if let status = licenseService.getLicenseStatus(for: licenseType) {
                    await MainActor.run {
                        verificationStatus = status
                        
                        if status == .verified {
                            isSubmitting = false
                            showSuccess = true
                        } else if status == .rejected {
                            isSubmitting = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("License Upload") {
    LicenseUploadScreen(licenseType: .electrician)
        .environment(Router())
        .environment(AppState())
}
