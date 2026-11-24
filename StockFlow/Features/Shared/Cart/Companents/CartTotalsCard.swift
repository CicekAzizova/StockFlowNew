//
//  CartTotalsCard.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Ara cəm, endirim və yekun məbləğ.
struct CartTotalsCard: View {

    let subtotal: Double
    let totalDiscount: Double
    let total: Double
    let onDiscountTap: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Subtotal")
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(verbatim: subtotal.asCurrency)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
            }
            .font(.subheadline)

            discountRow

            Divider()

            HStack {
                Text("Total")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(verbatim: total.asCurrency)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .brandCard()
    }

    private var discountRow: some View {
        Button(action: onDiscountTap) {
            HStack(spacing: 8) {
                Image(systemName: "percent")
                    .foregroundStyle(Color.brandTeal)

                Text(totalDiscount > 0 ? "Discount" : "Add discount")
                    .foregroundStyle(totalDiscount > 0 ? Color.textSecondary : Color.brandTeal)

                Spacer()

                if totalDiscount > 0 {
                    Text(verbatim: "−\(totalDiscount.asCurrency)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .font(.subheadline)
        }
        .buttonStyle(.plain)
    }
}
