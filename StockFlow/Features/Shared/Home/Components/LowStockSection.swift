//
//  LowStockSection.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import SwiftUI

struct LowStockSection: View {

    let products: [ProductsResponse]
    /// Bütün az qalan məhsulların sayı (siyahıda yalnız ilk bir neçəsi göstərilir).
    let totalCount: Int

    @Binding var path: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Low stock products (\(totalCount))")
                    .font(.inter(.bold, size: 18))
                    .foregroundStyle(.textPrimary)
                Spacer()

                if !products.isEmpty {
                    Button("See All") {
                        path.append(HomeRoute.lowStock)
                    }
                    .font(.inter(.medium, size: 13))
                    .foregroundStyle(.seeAllButton)
                }
            }

            if products.isEmpty {
                Text("No low stock products")
                    .font(.inter(.regular, size: 14))
                    .foregroundStyle(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                list
            }
        }
    }

    private var list: some View {
        VStack(spacing: 0) {
            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                Button {
                    path.append(ProductRoute.productDetail(product))
                } label: {
                    LowStockRow(product: product)
                }
                .buttonStyle(.plain)

                if index < products.count - 1 {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.border, lineWidth: 1)
        }
    }
}

/// Az qalan məhsulun yığcam sətri: şəkil, ad, SKU və qalıq nişanı.
private struct LowStockRow: View {

    let product: ProductsResponse

    var body: some View {
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
                .foregroundStyle(product.stockStatus.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(product.stockStatus.backgroundColor)
                .clipShape(Capsule())
        }
        .padding(12)
        .contentShape(Rectangle())
    }
}
