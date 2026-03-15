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
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                HXText(question, style: .body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $isPresented) {
            FAQDetailView(question: question)
        }
    }
}

// MARK: - FAQ Detail View
private struct FAQDetailView: View {
    let question: String
    
    private var answer: String {
        switch question {
        case "How do I complete a task?":
            return """
            To complete a task on HustleXP:
            
            1. **Browse available tasks** in your Feed or on the map
            2. **Accept a task** that matches your skills and availability
            3. **Travel to the location** - use the built-in navigation
            4. **Complete the work** as described in the task details
            5. **Submit proof** - take a photo and capture your GPS location
            6. **Wait for approval** - the poster will review your submission
            7. **Get paid!** - funds are released to your account once approved
            
            Tips for success:
            • Communicate with the poster if you have questions
            • Submit clear photos showing completed work
            • Be punctual and professional
            """
            
        case "How do I get paid?":
            return """
            HustleXP uses a secure escrow system for all payments:
            
            **Payment Flow:**
            1. Poster funds the task when creating it
            2. Funds are held securely in escrow
            3. Once you submit proof and it's approved, funds are released
            4. Money is deposited to your linked payment method
            
            **Payout Options:**
            • Instant transfer to debit card (small fee applies)
            • Standard bank transfer (1-3 business days, free)
            • Keep balance in HustleXP wallet
            
            **Fees:**
            • Platform fee: 15% of task value
            • Insurance contribution: 2% (protects you!)
            • XP Tax: 10% held until paid (if applicable)
            
            You can view your earnings breakdown in Profile → Earnings.
            """
            
        case "What if there's a problem with a task?":
            return """
            If you encounter issues with a task:
            
            **Communication First:**
            • Use in-app messaging to discuss with the other party
            • Many issues can be resolved through clear communication
            
            **Filing a Dispute:**
            1. Go to the task details
            2. Tap "Report Issue" or "File Dispute"
            3. Select the reason and provide details
            4. Our team will review within 24-48 hours
            
            **Dispute Outcomes:**
            • Full refund to poster
            • Full payment to worker
            • Partial resolution
            • Task cancellation with no penalty
            
            **Insurance Claims:**
            If you experienced damage or loss during a task, you may be eligible for an insurance claim. Go to Settings → File Claim.
            
            Our support team is available 9am-9pm PT via live chat.
            """
            
        case "How does verification work?":
            return """
            HustleXP uses multi-layer verification to keep everyone safe:
            
            **Identity Verification:**
            • Photo ID verification
            • Selfie matching
            • Background check (for premium tasks)
            
            **Proof Verification:**
            • GPS location capture
            • Timestamped photos
            • Biometric validation
            • AI fraud detection
            
            **Earned Verification:**
            After earning $40+ on the platform, you unlock free ID verification - no payment required!
            
            **Professional Licenses:**
            For tasks requiring specific skills (electrical, plumbing, etc.), you can upload your professional license for verification. This unlocks higher-paying tasks.
            
            Verified users get a badge on their profile and access to premium tasks.
            """
            
        case "How is my trust tier calculated?":
            return """
            Your Trust Tier reflects your reliability and track record:
            
            **Tier Levels:**
            • 🟢 Rookie (0-499 XP) - New to platform
            • 🔵 Trusted (500-1,499 XP) - Proven reliable
            • 🟣 Pro (1,500-3,499 XP) - Experienced hustler
            • 🟡 Elite (3,500-6,999 XP) - Top performer
            • ⭐ Legend (7,000+ XP) - Platform veteran
            
            **XP Earning:**
            • Complete tasks: 10-100 XP based on value
            • 5-star ratings: Bonus XP
            • Streak bonuses: Up to 1.5x multiplier
            • Speed bonuses: Complete quickly
            
            **XP Penalties:**
            • Cancelled tasks: -50 XP
            • Poor ratings: Reduced XP
            • Disputes against you: -100 XP
            
            Higher tiers unlock:
            • Premium task access
            • Lower platform fees
            • Priority matching
            • Exclusive features (Squads, etc.)
            """
            
        default:
            return "Information about this topic is coming soon. Please contact support if you need immediate assistance."
        }
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HXText(question, style: .title2)
                    
                    Text(answer)
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .lineSpacing(4)
                    
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
        .accessibilityLabel("\(title) feedback")
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
                    subtitle: "support@hustlexp.app"
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
        Button(action: handleContactAction) {
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
    
    private func handleContactAction() {
        switch title {
        case "Email Support":
            if let url = URL(string: "mailto:support@hustlexp.app") {
                UIApplication.shared.open(url)
            }
        case "Live Chat":
            // In production, this would open Intercom or similar
            HXLogger.debug("[Help] Opening live chat...", category: "General")
        case "Phone Support":
            if let url = URL(string: "tel://18005551234") {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
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
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                HXText(title, style: .body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $isPresented) {
            LegalDetailView(title: title)
        }
    }
}

// MARK: - Legal Detail View
private struct LegalDetailView: View {
    let title: String
    
    private var legalContent: String {
        switch title {
        case "Terms of Service":
            return """
            HUSTLEXP TERMS OF SERVICE
            Last Updated: February 2026
            
            1. ACCEPTANCE OF TERMS
            By accessing or using HustleXP, you agree to be bound by these Terms of Service and all applicable laws and regulations.
            
            2. SERVICE DESCRIPTION
            HustleXP is a platform connecting task posters with workers ("Hustlers") for completing various tasks and services.
            
            3. USER ACCOUNTS
            • You must be 18 years or older to use this service
            • You are responsible for maintaining account security
            • One account per person
            • Accurate information required
            
            4. PAYMENTS AND FEES
            • Platform fee: 15% of task value
            • Insurance contribution: 2%
            • Payments processed via Stripe
            • Funds held in escrow until task completion
            
            5. USER CONDUCT
            You agree NOT to:
            • Violate any laws or regulations
            • Harass, threaten, or harm others
            • Submit fraudulent proofs
            • Circumvent the platform for direct payments
            • Create multiple accounts
            
            6. DISPUTE RESOLUTION
            Disputes will be handled through our internal resolution process. Binding arbitration may apply.
            
            7. LIMITATION OF LIABILITY
            HustleXP is not liable for actions of users, task outcomes, or damages arising from platform use.
            
            8. MODIFICATIONS
            We reserve the right to modify these terms at any time. Continued use constitutes acceptance.
            
            For questions, contact: legal@hustlexp.com
            """
            
        case "Privacy Policy":
            return """
            HUSTLEXP PRIVACY POLICY
            Last Updated: February 2026
            
            1. INFORMATION WE COLLECT
            
            Personal Information:
            • Name, email, phone number
            • Government ID (for verification)
            • Payment information
            • Profile photos
            
            Usage Information:
            • GPS location (during task completion)
            • Device information
            • App usage patterns
            • Communication logs
            
            2. HOW WE USE YOUR INFORMATION
            • Facilitate task matching
            • Process payments
            • Verify identity and prevent fraud
            • Improve our services
            • Send notifications and updates
            • Resolve disputes
            
            3. INFORMATION SHARING
            We share data with:
            • Other users (profile info, ratings)
            • Payment processors (Stripe)
            • Identity verification services
            • Law enforcement (when required)
            
            We do NOT sell your personal data.
            
            4. DATA SECURITY
            • Encryption in transit and at rest
            • Regular security audits
            • Access controls and monitoring
            
            5. YOUR RIGHTS
            • Access your data
            • Request deletion
            • Opt out of marketing
            • Export your data
            
            6. DATA RETENTION
            We retain data for the duration of your account plus 7 years for legal compliance.
            
            Contact our DPO: privacy@hustlexp.com
            """
            
        case "Community Guidelines":
            return """
            HUSTLEXP COMMUNITY GUIDELINES
            
            Our mission is to create a safe, respectful, and trustworthy community for everyone.
            
            BE RESPECTFUL
            • Treat everyone with dignity
            • No harassment, discrimination, or hate speech
            • Communicate professionally
            • Respect privacy and boundaries
            
            BE HONEST
            • Provide accurate information
            • Complete tasks as described
            • Submit genuine proof photos
            • Report issues honestly
            
            BE RELIABLE
            • Show up on time
            • Communicate proactively
            • Complete accepted tasks
            • Respond to messages promptly
            
            BE SAFE
            • Follow all safety guidelines
            • Report unsafe situations
            • Don't share personal contact info until necessary
            • Meet in public spaces when possible
            
            PROHIBITED CONTENT
            • Illegal activities
            • Adult content
            • Violence or threats
            • Spam or scams
            • Fake reviews or ratings
            
            ENFORCEMENT
            Violations may result in:
            • Warning
            • Temporary suspension
            • Permanent ban
            • Legal action
            
            Report violations via the app or email: safety@hustlexp.com
            """
            
        default:
            return "Content for \(title) is being prepared."
        }
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(legalContent)
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .lineSpacing(4)
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
