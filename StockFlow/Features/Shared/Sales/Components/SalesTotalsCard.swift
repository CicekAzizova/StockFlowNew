//
//  SalesTotalsCard.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Dövriyyə / Satış sayı / Orta çek.
struct SalesTotalsCard: View {

    let totals: SalesTotalsResponse?

    var body: some View {
        VStack(spacing: 10) {
            StatsRow(items: items)

            if let difference {
                HStack(spacing: 4) {
                    Image(systemName: difference >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(verbatim: "\(abs(difference))")
                    Text("sales vs previous period")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(difference >= 0 ? Color.brandGreen : Color.brandCoral)
            }
        }
        .brandCard()
    }

    /// Satış sayının əvvəlki dövrlə fərqi (məs. 5 - 1 = 4). Dəyişiklik yoxdursa göstərilmir.
    private var difference: Int? {
        guard let totals else { return nil }
        let value = totals.orders - totals.previous.orders
        return value == 0 ? nil : value
    }

    private var items: [StatItem] {
        let revenue = totals?.revenue ?? 0
        let orders = totals?.orders ?? 0
        let average = totals?.averageCheck ?? 0

        return [
            StatItem(value: format(revenue), title: "Turnover"),
            StatItem(value: "\(orders)", title: "Sales count"),
            StatItem(value: format(average), title: "Average check")
        ]
    }

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}
