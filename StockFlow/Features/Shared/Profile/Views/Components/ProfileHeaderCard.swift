//
//  ProfileHeaderCard.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//
import SwiftUI

struct ProfileHeaderCard: View {

    let user: User
    let stats: [StatItem]
    let isUploadingAvatar: Bool
    let onAvatarTap: () -> Void
    let onEditTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            
            card
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                avatarButton

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName)
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(user.email)
                        .font(.footnote)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    badges
                        .padding(.top, 2)
                }
                .layoutPriority(1)

                Spacer(minLength: 0)

                if user.role == .owner {
                    editButton
                }
            }

            if !stats.isEmpty {
                Divider()

                StatsRow(items: stats)
            }
        }
        .brandCard()
    }

    private var avatarButton: some View {
        Button(action: onAvatarTap) {
            ProfileAvatarView(
                name: user.name,
                imageUrl: user.avatarUrl,
                size: 60,
                isLoading: isUploadingAvatar
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.brandTeal)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(Color.surface, lineWidth: 2)
                    }
                    .offset(x: 4, y: 4)
            }
        }
        .buttonStyle(.plain)
        .disabled(isUploadingAvatar)
    }

    private var badges: some View {
        HStack(spacing: 6) {
            ProfileBadge(
                user.role.displayName,
                systemImage: user.role == .owner ? "star.fill" : nil
            )

            if let storeName = user.storeName {
                ProfileBadge(verbatim: storeName)
            }
        }
    }

    private var editButton: some View {
        Button(action: onEditTap) {
            Image(systemName: "pencil")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 34, height: 34)
                .background(Color.brandTeal.opacity(0.10))
                .clipShape(Circle())
        }
        .accessibilityLabel("Edit")
    }
}
