//
//  ReportLocationsCard.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Məkanlar üzrə gəlir: ad, pay (%), məbləğ və doldurulmuş zolaq.
struct ReportLocationsCard: View {

    let locations: [ReportLocationSales]

    private var total: Double {
        locations.reduce(0) { $0 + $1.revenue }
    }

    private func share(_ location: ReportLocationSales) -> Double {
        total > 0 ? location.revenue / total : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By location")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            ForEach(locations) { location in
                row(location)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .brandCard()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ location: ReportLocationSales) -> some View {
        let share = share(location)

        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "storefront")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.brandGreen)
                    .frame(width: 32, height: 32)
                    .background(Color.brandGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                Text(verbatim: location.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(verbatim: "\(Int((share * 100).rounded()))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Text(verbatim: location.revenue.asCurrency)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))

                GeometryReader { geometry in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.brandGreen, .brandDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * share)
                }
            }
            .frame(height: 8)
        }
    }
}
