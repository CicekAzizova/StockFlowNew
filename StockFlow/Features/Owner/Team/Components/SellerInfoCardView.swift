//
//  SellerInfoCardView.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import SwiftUI

/// Komanda siyahısında bir satıcı sətri.
struct SellerInfoCardView: View {

    let associate: SellerResponse

    private var isDeactivated: Bool { associate.isDeactivated }

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text("\(associate.name) \(associate.surname)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                subtitle
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            trailing

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textSecondary.opacity(0.6))
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.border, lineWidth: 1)
        }
        .opacity(isDeactivated ? 0.55 : 1)
    }

    // MARK: - Avatar

    private var avatar: some View {
        SellerAvatar(associate: associate, size: 44)
            .grayscale(isDeactivated ? 1 : 0)
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(associate.isCurrentlyOnline && !isDeactivated
                          ? Color.brandGreen
                          : Color.textSecondary.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle().stroke(Color.surface, lineWidth: 2)
                    }
                    .offset(x: 3, y: 3)
            }
    }

    // MARK: - Subtitle

    /// "Onlayn · telefon", "2 saat əvvəl · telefon" və ya "Deaktivdir · telefon".
    @ViewBuilder
    private var subtitle: some View {
        HStack(spacing: 0) {
            if isDeactivated {
                Text("Deactivated")
                separator
            } else if associate.isCurrentlyOnline {
                Text("Online")
                separator
            } else if let date = associate.lastActiveDate {
                Text(date, format: .relative(presentation: .numeric, unitsStyle: .wide))
                separator
            }

            Text(verbatim: associate.phone)
        }
    }

    private var separator: some View {
        Text(verbatim: " · ")
    }

    // MARK: - Trailing

    @ViewBuilder
    private var trailing: some View {
        if isDeactivated {
            Text("Deactivated")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.textSecondary.opacity(0.12), in: Capsule())
        } else {
            VStack(alignment: .trailing, spacing: 2) {
                Text(associate.todaySales.asCurrency)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text("Today's Sales")
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}
