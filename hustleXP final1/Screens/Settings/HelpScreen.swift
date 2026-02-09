//
//  HelpScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct HelpScreen: View {
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.textSecondary)
                        
                        TextField("", text: $searchText, prompt: Text("Search help articles...").foregroundColor(.textTertiary))
                            .font(.body)
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(16)
                    .background(Color.surfaceElevated)
                    .cornerRadius(12)
                    
                    // Quick help section
                    QuickHelpSection()
                    
                    // FAQ Section
                    FAQSection()
                    
                    // Contact Section
                    ContactSection()
                    
                    // Legal Section
                    LegalSection()
                    
                    // App info
                    AppInfoSection()
                }
                .padding(24)
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Quick Help Section
private struct QuickHelpSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Quick Help", style: .headline)
            
            HStack(spacing: 12) {
                QuickHelpCard(
                    icon: "questionmark.circle.fill",
                    title: "Getting Started",
                    color: .brandPurple
                )
                
                QuickHelpCard(
                    icon: "dollarsign.circle.fill",
                    title: "Payments",
                    color: .moneyGreen
                )
                
                QuickHelpCard(
                    icon: "shield.fill",
                    title: "Safety",
                    color: .infoBlue
                )
            }
        }
    }
}

// MARK: - Quick Help Card
private struct QuickHelpCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                
                HXText(title, style: .caption)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAQ Section
private struct FAQSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Common Questions", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                FAQRow(question: "How do I complete a task?")
                HXDivider().padding(.leading, 16)
                FAQRow(question: "How do I get paid?")
                HXDivider().padding(.leading, 16)
                FAQRow(question: "What if there's a problem with a task?")
                HXDivider().padding(.leading, 16)
                FAQRow(question: "How does verification work?")
                HXDivider().padding(.leading, 16)
                FAQRow(question: "How is my trust tier calculated?")
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - FAQ Row
private struct FAQRow: View {
    let question: String
    
    var body: some View {
        NavigationLink(destination: FAQDetailView(question: question)) {
            HStack {
                HXText(question, style: .body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - FAQ Detail View
private struct FAQDetailView: View {
    let question: String
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HXText(question, style: .title2)
                    
                    HXText(
                        "This is a placeholder answer for the FAQ question. In a real app, this would contain helpful information about the topic.",
                        style: .body,
                        color: .textSecondary
                    )
                    
                    HXDivider()
                    
                    HXText("Was this helpful?", style: .subheadline)
                    
                    HStack(spacing: 12) {
                        FeedbackButton(title: "Yes", icon: "hand.thumbsup.fill")
                        FeedbackButton(title: "No", icon: "hand.thumbsdown.fill")
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Feedback Button
private struct FeedbackButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                HXText(title, style: .subheadline)
            }
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.surfaceElevated)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Contact Section
private struct ContactSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Contact Us", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ContactRow(
                    icon: "envelope.fill",
                    iconColor: .infoBlue,
                    title: "Email Support",
                    subtitle: "support@hustlexp.com"
                )
                
                HXDivider().padding(.leading, 56)
                
                ContactRow(
                    icon: "bubble.left.fill",
                    iconColor: .brandPurple,
                    title: "Live Chat",
                    subtitle: "Available 9am-9pm"
                )
                
                HXDivider().padding(.leading, 56)
                
                ContactRow(
                    icon: "phone.fill",
                    iconColor: .successGreen,
                    title: "Phone Support",
                    subtitle: "For urgent issues"
                )
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Contact Row
private struct ContactRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Legal Section
private struct LegalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Legal", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                LegalRow(title: "Terms of Service")
                HXDivider().padding(.leading, 16)
                LegalRow(title: "Privacy Policy")
                HXDivider().padding(.leading, 16)
                LegalRow(title: "Community Guidelines")
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Legal Row
private struct LegalRow: View {
    let title: String
    
    var body: some View {
        NavigationLink(destination: LegalDetailView(title: title)) {
            HStack {
                HXText(title, style: .body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - Legal Detail View
private struct LegalDetailView: View {
    let title: String
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HXText(
                        "This is placeholder legal content for \(title). In a real app, this would contain the full legal text.",
                        style: .body,
                        color: .textSecondary
                    )
                }
                .padding(24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - App Info Section
private struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: 8) {
            HXText("HustleXP", style: .headline)
            HXText("Version 1.0.0 (Build 1)", style: .caption, color: .textTertiary)
            HXText("Made with hustle", style: .caption, color: .textTertiary)
        }
        .padding(.top, 24)
    }
}

#Preview {
    NavigationStack {
        HelpScreen()
    }
}
