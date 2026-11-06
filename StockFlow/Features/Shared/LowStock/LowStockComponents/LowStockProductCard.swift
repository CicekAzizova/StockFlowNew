//
//  LowStockProductCard.swift
//  StockFlow
//
//  Created by Cicek on 06.11.26.
//

import SwiftUI

/// Az qalan məhsulun kartı: şəkil, ad, status, qalıq çubuğu və bu ayki satış.
struct LowStockProductCard: View {

    let product: ProductsResponse
    /// Verilərsə (owner), "Restock" düyməsi görünür. nil olsa düymə yoxdur.
    var onRestock: (() -> Void)? = nil

    /// Çubuğun doluluğu: qalıq / minimum hədd (0 ilə 1 arası).
    private var progress: Double {
        guard product.lowStockLimit > 0 else { return 0 }
        return min(Double(product.quantity) / Double(product.lowStockLimit), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            topRow
            progressBar
            footer
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        }
    }

    // MARK: - Parts

    private var topRow: some View {
        HStack(spacing: 12) {
            RemoteImageView(
                imageUrl: product.imageUrls?.first,
                width: 46,
                height: 46,
                cornerRadius: 12
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(verbatim: "SKU · \(product.sku)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(product.stockStatus.text(quantity: product.quantity))
                .font(.inter(.bold, size: 11))
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(product.stockStatus.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(product.stockStatus.backgroundColor)
                .clipShape(Capsule())

            if let onRestock {
                Button(action: onRestock) {
                    Label("Restock", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .fixedSize()
                        .foregroundStyle(Color.brandTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.brandTeal.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var progressBar: some View {
        Capsule()
            .fill(Color.border.opacity(0.6))
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    Capsule()
                        .fill(product.stockStatus.color)
                        .frame(width: max(6, geo.size.width * progress))
                }
            }
    }

    private var footer: some View {
        HStack {
            Text("Stock \(product.quantity) / min. \(product.lowStockLimit)")
            Spacer(minLength: 8)
            Text("Sold this month: \(product.soldThisMonth)")
        }
        .font(.caption)
        .foregroundStyle(Color.textSecondary)
        .lineLimit(1)
    }
}
