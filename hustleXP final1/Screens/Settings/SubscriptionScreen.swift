//
//  SubscriptionScreen.swift
//  hustleXP final1
//
//  Full subscription management screen for recurring task plans.
//  Plans: Premium ($9.99/mo) and Pro ($19.99/mo) with yearly discounts.
//

import SwiftUI
import StripePaymentSheet

struct SubscriptionScreen: View {
    @Environment(Router.self) private var router
    @State private var subscriptionService = SubscriptionService.shared
    @State private var isYearly = false
    @State private var showCancelConfirmation = false
    @State private var showPaymentConfirmation = false
    @State private var selectedPlan: SubscriptionService.SubscriptionPlan?
    @State private var paymentProcessing = false
    @State private var paymentError: String?
    @State private var paymentSuccess = false

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            if subscriptionService.isLoading && subscriptionService.currentPlan == .free {
                LoadingState(message: "Loading subscription...")
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        heroSection
                        currentPlanBadge
                        billingToggle
                        planCards
                        if subscriptionService.isSubscribed {
                            recurringTaskUsage
                            cancelSection
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Cancel Subscription?", isPresented: $showCancelConfirmation) {
            Button("Keep Plan", role: .cancel) {}
            Button("Cancel Plan", role: .destructive) {
                Task { await cancelSubscription() }
            }
        } message: {
            Text("You will lose access to recurring tasks at the end of your billing period. This cannot be undone.")
        }
        .sheet(isPresented: $showPaymentConfirmation) {
            if let plan = selectedPlan {
                PaymentConfirmationSheet(
                    title: "Subscribe to \(plan.displayName)",
                    description: plan == .premium
                        ? "Up to 5 recurring tasks, medium risk access, live tracking, priority matching"
                        : "Unlimited recurring tasks, high risk access, advanced analytics, priority support",
                    priceCents: isYearly ? plan.yearlyPriceCents : plan.monthlyPriceCents,
                    icon: plan.icon,
                    interval: isYearly ? "year" : "month",
                    onConfirm: {
                        await handleSubscribe(plan: plan)
                    },
                    onDismiss: {
                        showPaymentConfirmation = false
                        selectedPlan = nil
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            Task { await subscriptionService.fetchSubscription() }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "repeat.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.brandPurple)
            }

            HXText("Unlock Recurring Tasks", style: .title2)

            HXText(
                "Subscribe to create recurring tasks that auto-post on your schedule. Save time and build reliable hustler relationships.",
                style: .subheadline,
                color: .textSecondary
            )
            .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Current Plan Badge

    private var currentPlanBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: subscriptionService.currentPlan.icon)
                .font(.system(size: 20))
                .foregroundStyle(subscriptionService.currentPlan.color)

            VStack(alignment: .leading, spacing: 2) {
                HXText("Current Plan", style: .caption, color: .textSecondary)
                HXText(subscriptionService.currentPlan.displayName, style: .headline)
            }

            Spacer()

            if subscriptionService.isSubscribed, let expires = subscriptionService.expiresAt {
                VStack(alignment: .trailing, spacing: 2) {
                    HXText("Renews", style: .caption, color: .textSecondary)
                    HXText(expires.formatted(.dateTime.month(.abbreviated).day()), style: .caption)
                }
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(subscriptionService.currentPlan.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Billing Toggle

    private var billingToggle: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isYearly = false }
            } label: {
                Text("Monthly")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(!isYearly ? .white : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(!isYearly ? Color.brandPurple : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isYearly = true }
            } label: {
                HStack(spacing: 4) {
                    Text("Yearly")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isYearly ? .white : .textSecondary)
                    Text("Save 33%")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(isYearly ? .successGreen : .successGreen.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isYearly ? Color.brandPurple : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(4)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Plan Cards

    private var planCards: some View {
        HStack(spacing: 12) {
            planCard(for: .premium)
            planCard(for: .pro)
        }
    }

    private func planCard(for plan: SubscriptionService.SubscriptionPlan) -> some View {
        let isCurrent = subscriptionService.currentPlan == plan
        let priceCents = isYearly ? plan.yearlyPriceCents : plan.monthlyPriceCents
        let priceLabel = String(format: "$%.2f", Double(priceCents) / 100.0)
        let interval = isYearly ? "/yr" : "/mo"

        return VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: plan.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(plan.color)
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(plan.color)
                        .clipShape(Capsule())
                }
            }

            // Plan name
            Text(plan.displayName)
                .font(.headline.weight(.bold))
                .foregroundColor(.textPrimary)

            // Price
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(priceLabel)
                    .font(.title2.weight(.bold))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.textPrimary)
                Text(interval)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            // Divider
            Rectangle()
                .fill(Color.borderSubtle)
                .frame(height: 1)

            // Features
            VStack(alignment: .leading, spacing: 8) {
                if plan == .premium {
                    featureRow(icon: "repeat", text: "Up to 5 recurring tasks")
                    featureRow(icon: "exclamationmark.triangle", text: "Medium risk access")
                    featureRow(icon: "location.fill", text: "Live tracking")
                    featureRow(icon: "person.2", text: "Priority matching")
                } else {
                    featureRow(icon: "repeat", text: "Unlimited recurring tasks")
                    featureRow(icon: "exclamationmark.triangle.fill", text: "High risk access")
                    featureRow(icon: "chart.bar.fill", text: "Advanced analytics")
                    featureRow(icon: "headphones", text: "Priority support")
                }
            }

            Spacer(minLength: 4)

            // CTA
            if isCurrent {
                HStack {
                    Spacer()
                    Text("Active")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(plan.color)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(plan.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    selectedPlan = plan
                    showPaymentConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Subscribe")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [plan.color, plan.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: plan.color.opacity(0.4), radius: 8, y: 4)
                }
                .accessibilityLabel("Subscribe to \(plan.displayName)")
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isCurrent ? plan.color.opacity(0.5) : Color.borderSubtle,
                    lineWidth: isCurrent ? 2 : 1
                )
        )
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(Color.brandPurple)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    // MARK: - Recurring Task Usage

    private var recurringTaskUsage: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Recurring Task Usage", style: .headline)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.recurringBlue.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "repeat")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.recurringBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HXText(subscriptionService.slotsDisplay, style: .subheadline)

                    if subscriptionService.currentPlan != .pro {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.surfaceSecondary)
                                    .frame(height: 6)

                                let ratio = subscriptionService.recurringTaskLimit > 0
                                    ? CGFloat(subscriptionService.recurringTaskCount) / CGFloat(subscriptionService.recurringTaskLimit)
                                    : 0
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.recurringBlue)
                                    .frame(width: geometry.size.width * min(ratio, 1.0), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cancel Section

    private var cancelSection: some View {
        Button {
            showCancelConfirmation = true
        } label: {
            HStack {
                Spacer()
                HXText("Cancel Subscription", style: .subheadline, color: .errorRed)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(Color.errorRed.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("Cancel subscription")
    }

    // MARK: - Actions

    private func handleSubscribe(plan: SubscriptionService.SubscriptionPlan) async {
        let interval = isYearly ? "yearly" : "monthly"
        guard let clientSecret = await subscriptionService.subscribe(plan: plan.rawValue, interval: interval) else {
            return
        }

        // Present Stripe PaymentSheet
        let stripe = StripePaymentManager.shared
        stripe.preparePaymentSheet(clientSecret: clientSecret, merchantDisplayName: "HustleXP")
        let result = await stripe.presentPaymentSheet()

        switch result {
        case .completed:
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
            showPaymentConfirmation = false
            selectedPlan = nil
            await subscriptionService.fetchSubscription()
        case .canceled:
            break
        case .failed(let error):
            paymentError = error.localizedDescription
        }
    }

    private func cancelSubscription() async {
        let success = await subscriptionService.cancel()
        if success {
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionScreen()
    }
    .environment(Router())
}
