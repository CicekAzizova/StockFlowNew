//
//  ProductStatsCard.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Qiymət kartı. Sahibdə: satış, alış, qazanc. Satıcıda: satış qiyməti və barkod.
struct ProductStatsCard: View {

    let product: ProductsResponse
    let showsCost: Bool

    /// Marja: qazanc / satış qiyməti. Alış qiyməti yoxdursa (0) göstərilmir.
    private var marginText: String {
        guard product.costPrice > 0, product.price > 0 else { return "—" }
        let margin = (product.price - product.costPrice) / product.price * 100
        return "\(Int(margin.rounded()))%"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            column("Selling price", product.price.asCurrency)

            if showsCost {
                divider
                column("Cost price", product.costPrice > 0 ? product.costPrice.asCurrency : "—")
                divider
                column("Margin", marginText, tint: product.costPrice > 0 ? Color.brandTeal : nil)
            } else {
                divider
                column("Barcode", product.sku)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 1, height: 36)
            .padding(.top, 2)
    }

    private func column(_ title: LocalizedStringKey, _ value: String, tint: Color? = nil) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.inter(.regular, size: 12))
                .foregroundStyle(.textSecondary)
            Text(verbatim: value)
                .font(.inter(.bold, size: 17))
                .foregroundStyle(tint ?? Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}
