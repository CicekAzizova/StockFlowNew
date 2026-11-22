//
//  LocationStockCard.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//
import SwiftUI

/// Bir məkanın qalığı: ikon, ad, növ, vəziyyət nişanı, say və doluluq xətti.
struct LocationStockCard: View {

    let name: String
    let location: StoreLocation?
    let quantity: Int
    let lowStockLimit: Int

    private var status: StockStatus {
        if quantity == 0 { return .outOfStock }
        if quantity <= lowStockLimit { return .lowStock }
        return .inStock
    }

    private var statusTitle: LocalizedStringKey {
        switch status {
        case .inStock: "Normal"
        case .lowStock: "Low"
        case .outOfStock: "Out"
        }
    }

    private var isWarehouse: Bool { location?.kind == .warehouse }

    private var kindTitle: LocalizedStringKey {
        if isWarehouse { return "Warehouse" }
        return location?.isMain == true ? "Main store" : "Store"
    }

    private var iconTint: Color { isWarehouse ? .purple : .brandTeal }

    /// Xətt limitin 3 qatında dolur.
    private var progress: Double {
        let full = Double(max(lowStockLimit, 1) * 3)
        return min(Double(quantity) / full, 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: isWarehouse ? "building.2" : "storefront")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconTint)
                    .frame(width: 44, height: 44)
                    .background(iconTint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: name)
                        .font(.inter(.bold, size: 14))
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                    Text(kindTitle)
                        .font(.inter(.regular, size: 11))
                        .foregroundStyle(.textSecondary)
                }

                Spacer(minLength: 8)

                Text(statusTitle)
                    .font(.inter(.bold, size: 12))
                    .foregroundStyle(status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(status.backgroundColor, in: Capsule())

                Text("\(quantity) units")
                    .font(.inter(.bold, size: 14))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .fixedSize()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(status.color)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
