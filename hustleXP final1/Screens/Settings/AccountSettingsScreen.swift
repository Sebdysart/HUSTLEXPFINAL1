//
//  AccountSettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct AccountSettingsScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false
    @State private var showDeleteSuccess: Bool = false
    @State private var deleteError: String?
    
    var body: some View {
        List {
            // Profile section
            Section {
                AccountInfoRow(label: "Name", value: dataService.currentUser.name)
                AccountInfoRow(label: "Email", value: dataService.currentUser.email)
                AccountInfoRow(label: "Phone", value: dataService.currentUser.phone ?? "Not set")
                AccountInfoRow(label: "Role", value: appState.userRole?.rawValue.capitalized ?? "—")
            } header: {
                Text("Profile")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Trust & Reputation
            Section {
                HStack {
                    HXText("Trust Tier", style: .body)
                    Spacer()
                    HXBadge(variant: .tier(dataService.currentUser.trustTier))
                }
                
                HStack {
                    HXText("Rating", style: .body)
                    Spacer()
                    RatingStars(rating: dataService.currentUser.rating, mode: .display)
                }
                
                AccountInfoRow(label: "Total Ratings", value: "\(dataService.currentUser.totalRatings)")
                AccountInfoRow(label: "XP", value: "\(dataService.currentUser.xp)")
            } header: {
                Text("Trust & Reputation")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Actions
            Section {
                Button { router.navigateToSettings(.editProfile) } label: {
                    HStack {
                        HXIcon("pencil", size: .small, color: .infoBlue)
                        HXText("Edit Profile", style: .body, color: .infoBlue)
                    }
                }
                .accessibilityLabel("Edit profile")

                Button { router.navigateToSettings(.changePassword) } label: {
                    HStack {
                        HXIcon("key.fill", size: .small, color: .infoBlue)
                        HXText("Change Password", style: .body, color: .infoBlue)
                    }
                }
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Danger zone
            Section {
                Button(action: { showDeleteConfirmation = true }) {
                    HStack {
                        HXIcon("trash.fill", size: .small, color: .errorRed)
                        HXText("Delete Account", style: .body, color: .errorRed)
                    }
                }
                .accessibilityLabel("Delete account")
            } footer: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
            .listRowBackground(Color.surfaceElevated)
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.brandBlack)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Your account will be scheduled for deletion. You have 7 days to cancel. After that, all data will be permanently removed.")
        }
        .alert("Account Deletion Requested", isPresented: $showDeleteSuccess) {
            Button("OK") {
                AuthService.shared.signOut()
            }
        } message: {
            Text("Your account has been scheduled for deletion. You have 7 days to log back in and cancel if you change your mind.")
        }
    }

    private func deleteAccount() {
        isDeleting = true
        deleteError = nil

        Task {
            do {
                _ = try await GDPRService.shared.requestAccountDeletion(reason: "User requested deletion")
                isDeleting = false
                showDeleteSuccess = true
            } catch {
                isDeleting = false
                deleteError = error.localizedDescription
                HXLogger.error("Account deletion failed: \(error.localizedDescription)", category: "Settings")
            }
        }
    }
}

struct AccountInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HXText(label, style: .body)
            Spacer()
            HXText(value, style: .body, color: .textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        AccountSettingsScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
