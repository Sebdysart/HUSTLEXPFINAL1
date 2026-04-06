//
//  EditProfileScreen.swift
//  hustleXP final1
//
//  Edit profile form — updates name, bio, phone via user.updateProfile tRPC
//

import SwiftUI
import PhotosUI

struct EditProfileScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(LiveDataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var phone: String = ""
    @State private var avatarImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, bio, phone
    }

    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasChanges: Bool {
        let user = dataService.currentUser
        return displayName != user.name
            || bio != (user.bio ?? "")
            || phone != (user.phone ?? "")
            || avatarImage != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar
                avatarSection

                // Form fields
                formSection

                // Save button
                saveButton
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBlack)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { loadCurrentValues() }
        .alert("Profile Updated", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        }
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        VStack(spacing: 12) {
            Button { showPhotoPicker = true } label: {
                ZStack(alignment: .bottomTrailing) {
                    if let avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.brandPurple, lineWidth: 3))
                    } else if let url = dataService.currentUser.avatarURL {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.brandPurple, lineWidth: 3))
                    } else {
                        Circle()
                            .fill(Color.surfaceElevated)
                            .frame(width: 100, height: 100)
                            .overlay(
                                HXText(
                                    String(displayName.prefix(2)).uppercased(),
                                    style: .largeTitle,
                                    color: .brandPurple
                                )
                            )
                            .overlay(Circle().stroke(Color.borderSubtle, lineWidth: 1))
                    }

                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            .buttonStyle(.plain)
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        avatarImage = image
                    }
                }
            }

            Text("Change Photo")
                .font(.subheadline)
                .foregroundStyle(Color.brandPurple)
        }
        .padding(.top, 8)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 20) {
            // Name
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("Display Name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    Text("*")
                        .foregroundStyle(Color.errorRed)
                }

                TextField("Your name", text: $displayName)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .name ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }

            // Bio
            VStack(alignment: .leading, spacing: 6) {
                Text("Bio")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2...4)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .bio ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .bio)

                HStack {
                    Text("Optional")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    Spacer()
                    Text("\(bio.count)/500")
                        .font(.caption)
                        .foregroundStyle(bio.count > 500 ? Color.errorRed : Color.textMuted)
                }
            }

            // Phone
            VStack(alignment: .leading, spacing: 6) {
                Text("Phone")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                TextField("e.g. +1 555-123-4567", text: $phone)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .phone ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)

                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.errorRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button(action: save) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isValid && hasChanges && !isSaving ? Color.brandPurple : Color.textMuted.opacity(0.5))
            )
        }
        .disabled(!isValid || !hasChanges || isSaving)
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func loadCurrentValues() {
        let user = dataService.currentUser
        displayName = user.name
        bio = user.bio ?? ""
        phone = user.phone ?? ""
    }

    private func save() {
        guard isValid else { return }
        focusedField = nil
        isSaving = true
        errorMessage = nil

        Task {
            do {
                // Upload avatar if changed
                var avatarURL: String?
                if let avatarImage {
                    avatarURL = try await R2UploadService.shared.uploadPhoto(
                        avatarImage,
                        purpose: .avatar,
                        taskId: nil
                    )
                }

                let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

                let updatedUser = try await UserProfileService.shared.updateProfile(
                    name: trimmedName,
                    bio: trimmedBio.isEmpty ? nil : trimmedBio,
                    phone: trimmedPhone.isEmpty ? nil : trimmedPhone,
                    avatarURL: avatarURL
                )

                appState.userName = updatedUser.name
                isSaving = false
                showSuccess = true
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileScreen()
    }
    .environment(AppState())
    .environment(LiveDataService.shared)
}
