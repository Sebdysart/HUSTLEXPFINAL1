//
//  ShareTaskButton.swift
//  hustleXP final1
//
//  Molecule: ShareTaskButton
//  Reusable share button that generates a deep link for a task
//  and presents the system share sheet (UIActivityViewController).
//
//  Design: brandPurple glow accent, neon/dark aesthetic.
//

import SwiftUI

struct ShareTaskButton: View {
    /// The task ID used to build the deep link URL.
    let taskId: String

    /// The task title included in the share text.
    let taskTitle: String

    /// Visual variant — `.icon` shows only the SF Symbol,
    /// `.full` shows icon + label.
    var variant: Variant = .icon

    /// Optional custom tint (defaults to brandPurple).
    var tint: Color = .brandPurple

    /// Size of the button (maps to HXButtonSize semantics).
    var size: Size = .medium

    // MARK: - State

    @State private var isShowingShareSheet = false

    // MARK: - Types

    enum Variant {
        case icon       // Compact icon-only (e.g. inside a card header)
        case full       // Icon + "Share" label (e.g. action bar)
        case pill       // Rounded pill with label and glow
    }

    enum Size {
        case small, medium, large

        var iconFont: Font {
            switch self {
            case .small:  return .system(size: 14, weight: .semibold)
            case .medium: return .system(size: 16, weight: .semibold)
            case .large:  return .system(size: 18, weight: .bold)
            }
        }

        var labelFont: Font {
            switch self {
            case .small:  return .caption.weight(.semibold)
            case .medium: return .subheadline.weight(.semibold)
            case .large:  return .body.weight(.bold)
            }
        }

        var padding: CGFloat {
            switch self {
            case .small:  return 8
            case .medium: return 10
            case .large:  return 14
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small:  return 8
            case .medium: return 10
            case .large:  return 14
            }
        }
    }

    // MARK: - Computed

    /// The shareable URL for this task.
    private var shareURL: URL {
        DeepLinkManager.taskURL(taskId: taskId)
    }

    /// The text payload sent through the share sheet.
    private var shareText: String {
        "Check out this task on HustleXP: \(taskTitle)\n\(shareURL.absoluteString)"
    }

    // MARK: - Body

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            isShowingShareSheet = true
        } label: {
            switch variant {
            case .icon:
                iconLabel
            case .full:
                fullLabel
            case .pill:
                pillLabel
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(items: [shareText, shareURL])
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .accessibilityLabel("Share task")
        .accessibilityHint("Opens share sheet with a link to this task")
    }

    // MARK: - Variant Views

    /// Icon-only variant — a circular button with a glow ring.
    private var iconLabel: some View {
        Image(systemName: "square.and.arrow.up")
            .font(size.iconFont)
            .foregroundStyle(tint)
            .frame(width: size.padding * 3.2, height: size.padding * 3.2)
            .background(
                Circle()
                    .fill(tint.opacity(0.12))
            )
            .overlay(
                Circle()
                    .stroke(tint.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: tint.opacity(0.35), radius: 6, x: 0, y: 2)
    }

    /// Full variant — icon + "Share" label, horizontal layout.
    private var fullLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "square.and.arrow.up")
                .font(size.iconFont)
            Text("Share")
                .font(size.labelFont)
                .tracking(0.3)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, size.padding * 1.4)
        .padding(.vertical, size.padding * 0.8)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.3), radius: 6, x: 0, y: 2)
    }

    /// Pill variant — rounded capsule with glow, matches HXButton energy.
    private var pillLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.and.arrow.up")
                .font(size.iconFont)
                .shadow(color: .white.opacity(0.3), radius: 3)
            Text("Share Task")
                .font(size.labelFont)
                .tracking(0.5)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size.padding * 2)
        .padding(.vertical, size.padding)
        .background(
            ZStack {
                LinearGradient(
                    colors: [tint, Color.aiPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Shimmer overlay
                RoundedRectangle(cornerRadius: size.cornerRadius + 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius + 4)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius + 4))
        .shadow(
            color: tint.opacity(0.5),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

// MARK: - UIKit Share Sheet Bridge

/// Wraps UIActivityViewController for SwiftUI presentation.
private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        VStack(spacing: 32) {
            HXText("Share Variants", style: .title3)

            // Icon variant (default)
            HStack(spacing: 24) {
                ShareTaskButton(
                    taskId: "preview-task-001",
                    taskTitle: "Walk my dog",
                    variant: .icon,
                    size: .small
                )
                ShareTaskButton(
                    taskId: "preview-task-001",
                    taskTitle: "Walk my dog",
                    variant: .icon,
                    size: .medium
                )
                ShareTaskButton(
                    taskId: "preview-task-001",
                    taskTitle: "Walk my dog",
                    variant: .icon,
                    size: .large
                )
            }

            // Full variant
            ShareTaskButton(
                taskId: "preview-task-001",
                taskTitle: "Walk my dog",
                variant: .full,
                size: .medium
            )

            // Pill variant (primary CTA style)
            ShareTaskButton(
                taskId: "preview-task-001",
                taskTitle: "Walk my dog",
                variant: .pill,
                size: .large
            )

            // Custom tint
            ShareTaskButton(
                taskId: "preview-task-002",
                taskTitle: "Deliver groceries",
                variant: .full,
                tint: .accentViolet,
                size: .medium
            )
        }
        .padding(24)
    }
}
