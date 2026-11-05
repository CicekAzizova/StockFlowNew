//
//  SalesAssociateActionsCard.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

struct SalesAssociateActionsCard: View {
    let isDeactivated: Bool
    let isBusy: Bool
    let onToggleActiveTap: () -> Void
    let onDeleteTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if isDeactivated {
                actionButton(
                    title: "Activate account",
                    systemImage: "play.circle",
                    tint: .brandGreen,
                    action: onToggleActiveTap
                )
            } else {
                actionButton(
                    title: "Deactivate account",
                    systemImage: "pause.circle",
                    tint: .orange,
                    action: onToggleActiveTap
                )
            }

            actionButton(
                title: "Delete account",
                systemImage: "trash",
                tint: .red,
                action: onDeleteTap
            )
        }
        .disabled(isBusy)
    }

    private func actionButton(
        title: LocalizedStringKey,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
