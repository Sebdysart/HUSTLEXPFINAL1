//
//  NotificationCenterScreen.swift
//  hustleXP final1
//
//  v2.5.0: Notification inbox — displays all in-app notifications
//  Wired to backend notification.getList via NotificationService
//

import SwiftUI

struct NotificationCenterScreen: View {
    @Environment(Router.self) private var router
    @StateObject private var notificationService = NotificationService.shared

    @State private var notifications: [HXNotification] = []
    @State private var isLoading = true
    @State private var isLoadingMore = false
    @State private var hasMore = true

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            if isLoading {
                LoadingState(message: "Loading notifications...")
            } else if notifications.isEmpty {
                emptyState
            } else {
                notificationList
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if notificationService.unreadCount > 0 {
                    Button(action: markAllRead) {
                        Text("Read All")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.brandPurple)
                    }
                }
            }
        }
        .task {
            await loadNotifications()
        }
        .refreshable {
            await loadNotifications()
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "bell.slash",
            title: "No Notifications",
            message: "You're all caught up. Notifications about tasks, payments, and messages will appear here."
        )
    }

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notifications) { notification in
                    Button {
                        handleTap(notification)
                    } label: {
                        NotificationRow(notification: notification)
                    }
                    .buttonStyle(.plain)

                    HXDivider()
                        .padding(.leading, 64)
                }

                // Load more trigger
                if hasMore && !isLoadingMore {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task { await loadMore() }
                        }
                }

                if isLoadingMore {
                    ProgressView()
                        .tint(Color.brandPurple)
                        .padding()
                }
            }
        }
    }

    private func loadNotifications() async {
        isLoading = notifications.isEmpty
        do {
            notifications = try await notificationService.getNotifications(limit: 50, offset: 0)
            hasMore = notifications.count >= 50
            _ = try? await notificationService.getUnreadCount()
        } catch {
            HXLogger.error("NotificationCenter: Failed to load - \(error.localizedDescription)", category: "Push")
        }
        isLoading = false
    }

    private func loadMore() async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        do {
            let more = try await notificationService.getNotifications(limit: 50, offset: notifications.count)
            notifications.append(contentsOf: more)
            hasMore = more.count >= 50
        } catch {
            HXLogger.error("NotificationCenter: Failed to load more - \(error.localizedDescription)", category: "Push")
        }
        isLoadingMore = false
    }

    private func markAllRead() {
        Task {
            try? await notificationService.markAllAsRead()
            await loadNotifications()
        }
    }

    private func handleTap(_ notification: HXNotification) {
        // Mark as read + clicked
        Task {
            try? await notificationService.markAsRead(notificationId: notification.id)
            try? await notificationService.markAsClicked(notificationId: notification.id)
        }

        // Navigate based on notification data
        if let taskId = notification.data?["taskId"] {
            router.navigateToHustler(.taskDetail(taskId: taskId))
        }
    }
}

// MARK: - Notification Row

private struct NotificationRow: View {
    let notification: HXNotification

    private var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: notification.category.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HXText(
                        notification.title,
                        style: notification.isRead ? .subheadline : .headline
                    )
                    .lineLimit(1)

                    Spacer()

                    HXText(timeString, style: .caption, color: .textTertiary)
                }

                HXText(
                    notification.body,
                    style: .caption,
                    color: notification.isRead ? .textTertiary : .textSecondary
                )
                .lineLimit(2)
            }

            // Unread dot
            if !notification.isRead {
                Circle()
                    .fill(Color.brandPurple)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(notification.isRead ? Color.clear : Color.brandPurple.opacity(0.05))
        .contentShape(Rectangle())
    }

    private var iconColor: Color {
        switch notification.category {
        case .paymentReceived, .paymentSent:
            return .moneyGreen
        case .taskAccepted, .taskCompleted, .proofApproved:
            return .successGreen
        case .proofRejected:
            return .errorRed
        case .messageReceived:
            return .brandPurple
        case .ratingReceived:
            return .warningOrange
        case .tierUp, .badgeEarned:
            return .infoBlue
        default:
            return .textSecondary
        }
    }
}

#Preview {
    NavigationStack {
        NotificationCenterScreen()
    }
    .environment(Router())
}
