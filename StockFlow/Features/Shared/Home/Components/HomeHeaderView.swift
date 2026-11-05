//
//  HomeHeaderView.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import SwiftUI

/// Panelin gradient başlığı: salam, mağaza adı və bildiriş zəngi.
struct HomeHeaderView: View {

    let user: User
    var onNotificationsTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, \(user.name)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Text(user.storeName ?? "")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            BrandHeaderIconButton(
                systemImage: "bell",
                accessibilityLabel: "Notifications",
                action: onNotificationsTap
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .brandHeaderBackground()
    }
}
