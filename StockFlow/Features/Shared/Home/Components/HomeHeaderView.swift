//
//  HomeHeaderView.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import SwiftUI

/// Panelin gradient başlığı: salam, mağaza adı, bildiriş zəngi
/// və bu günkü satış (dünənlə müqayisə ilə).
struct HomeHeaderView: View {

    let user: User
    let todaySales: Double
    let todayOrders: Int
    /// Bu gün − dünən. nil olsa müqayisə göstərilmir.
    let differenceFromYesterday: Double?
    var onNotificationsTap: () -> Void = {}
    let weeklySales: [DailySales]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                salesBlock
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            // Qrafik üçün aşağıda yer qalır (kart bu hissəyə girir).
            .padding(.bottom, weeklySales.isEmpty ? 24 : 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .brandHeaderBackground()

            if !weeklySales.isEmpty {
                WeeklySalesChartView(days: weeklySales)
                    .padding(.horizontal, 16)
                    .padding(.top, -110)
                    .padding(.bottom, 8)
            }
        }
    }

    private var topRow: some View {
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
    }

    private var salesBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's sales")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Text(todaySales.asCurrency)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 8) {
                if let differenceFromYesterday {
                    comparisonBadge(differenceFromYesterday)
                }

                Text("\(todayOrders) sales")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private func comparisonBadge(_ difference: Double) -> some View {
        let isUp = difference >= 0
        let arrow = isUp ? "▲" : "▼"

        return HStack(spacing: 4) {
            Text(arrow)
            Text(abs(difference).asCurrency)
            Text("vs yesterday")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(isUp ? Color.success : Color.error)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(.white.opacity(0.9)))
    }

}
