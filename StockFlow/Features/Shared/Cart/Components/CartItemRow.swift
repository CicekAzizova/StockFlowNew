//
//  CartItemRow.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Səbətdə bir məhsul: şəkil, ad, qiymət, − say +, sətir cəmi.
struct CartItemRow: View {

    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(
                imageUrl: item.product.imageUrls?.first,
                width: 46,
                height: 46,
                cornerRadius: 12
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: item.product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                priceLine
            }

            Spacer(minLength: 4)

            stepper

            Text(verbatim: item.lineTotal.asCurrency)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.textPrimary)
                .frame(minWidth: 56, alignment: .trailing)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Hissələr

    private var priceLine: some View {
        HStack(spacing: 6) {
            Text(verbatim: item.product.discountedPrice.asCurrency)
                .foregroundStyle(Color.textSecondary)

            if item.product.hasDiscount {
                Text(verbatim: item.product.price.asCurrency)
                    .strikethrough()
                    .foregroundStyle(Color.textSecondary.opacity(0.6))
            }
        }
        .font(.caption)
    }

    private var stepper: some View {
        HStack(spacing: 6) {
            stepButton(systemImage: "minus", action: onDecrement)

            Text(verbatim: "\(item.quantity)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .frame(minWidth: 20)

            stepButton(systemImage: "plus", action: onIncrement)
                .disabled(!item.canIncrement)
                .opacity(item.canIncrement ? 1 : 0.4)
        }
        .padding(4)
        .background(Color.background, in: Capsule())
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 28, height: 28)
                .background(Color.surface, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
