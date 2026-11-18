//
//  StockFilterChips.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

/// Qalıq üzrə filtr çipləri (rəqəmlərlə).
struct StockFilterChips: View {

    @Binding var selected: ProductStockFilter
    let stats: ProductStats?

    private struct Chip: Identifiable {
        let filter: ProductStockFilter
        let title: LocalizedStringKey
        let count: Int?
        var id: ProductStockFilter { filter }
    }

    private var chips: [Chip] {
        [
            Chip(filter: .all, title: "All", count: stats?.total),
            Chip(filter: .inStock, title: "In stock", count: stats?.inStock),
            Chip(filter: .lowStock, title: "Low", count: stats?.lowStock),
            Chip(filter: .outStock, title: "Out", count: stats?.outOfStock)
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    let isSelected = selected == chip.filter
                    Button {
                        selected = chip.filter
                    } label: {
                        HStack(spacing: 5) {
                            Text(chip.title)
                            if let count = chip.count {
                                Text(verbatim: "\(count)")
                            }
                        }
                        .font(.inter(.bold, size: 13))
                        .foregroundStyle(isSelected ? Color.brandTeal : Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            isSelected ? Color.white : Color.white.opacity(0.2),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
