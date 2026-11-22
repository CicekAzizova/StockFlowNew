//
//  ProductRowView.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

/// Məhsullar siyahısında bir məhsul sətri.
struct ProductRowView: View {

    let product: ProductsResponse
    
    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager

    /// "food.dairy" → "food". Alt kateqoriyası yoxdursa nil.
    private var mainCategory: String {
        product.subcategory?.split(separator: ".").first.map(String.init) ?? ""
    }

    /// Alt kateqoriyanın tərcümə olunmuş adı, tapılmasa köhnə category.
    private var categoryName: String {
        if let code = product.subcategory,
           let name = catalogStore.subcategory(code: code)?
               .names.value(for: languageManager.language) {
            return name
        }
        return product.category
    }

    private var subtitle: String {
        [product.sku, categoryName]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: product.name)
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)

                Text(verbatim: subtitle)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(1)
                
                if !product.isForSale {
                    Label("Not for sale", systemImage: "pause.circle")
                        .font(.inter(.bold, size: 11))
                        .foregroundStyle(.textSecondary)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 5) {
                priceView
                stockBadge
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(product.isForSale ? 1 : 0.55)
    }

    // MARK: - Şəkil və ya ikon

    @ViewBuilder
    private var thumbnail: some View {
        if let url = product.imageUrls?.first, !url.isEmpty {
            RemoteImageView(imageUrl: url, width: 48, height: 48, cornerRadius: 12)
        } else {
            let tint = CategoryStyle.tint(for: mainCategory)
            Image(systemName: CategoryStyle.icon(for: mainCategory))
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Qiymət

    private var priceView: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(product.discountedPrice.asCurrency)
                .font(.inter(.bold, size: 15))
                .foregroundStyle(.textPrimary)

            if product.hasDiscount {
                Text(product.price.asCurrency)
                    .font(.inter(.regular, size: 11))
                    .foregroundStyle(.textSecondary)
                    .strikethrough()
            }
        }
    }

    // MARK: - Qalıq nişanı

    private var stockBadge: some View {
        Text(product.stockStatus.text(quantity: product.quantity))
            .font(.inter(.bold, size: 11))
            .foregroundStyle(product.stockStatus.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(product.stockStatus.backgroundColor, in: Capsule())
    }
}
