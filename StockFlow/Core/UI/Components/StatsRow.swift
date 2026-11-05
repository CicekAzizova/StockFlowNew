//
//  StatsRow.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

struct StatItem {
    let value: String
    let title: LocalizedStringKey
}

/// Yan-yana statistikalar (bölücü xətlərlə). Kartın içində istifadə olunur.
struct StatsRow: View {

    let items: [StatItem]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Divider()
                        .frame(height: 24)
                }

                VStack(spacing: 1) {
                    Text(verbatim: item.value)
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(item.title)
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
