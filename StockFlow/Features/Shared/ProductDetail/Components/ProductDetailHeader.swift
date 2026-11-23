//
//  ProductDetailHeader.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Gradient başlıq: geri, redaktə, "..." düymələri, məhsulun şəkli/ikonu, ad və alt yazı.
struct ProductDetailHeader<MenuContent: View>: View {

    let product: ProductsResponse
    let subtitle: String
    let onBack: () -> Void
    var onEdit: (() -> Void)? = nil
    var shareText: String? = nil
    @ViewBuilder var menu: MenuContent

    private var mainCategory: String {
        product.subcategory?.split(separator: ".").first.map(String.init) ?? ""
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                BrandHeaderIconButton(
                    systemImage: "chevron.left",
                    accessibilityLabel: "Back",
                    action: onBack
                )

                Spacer()
                
                if let shareText {
                    ShareLink(item: shareText) {
                        BrandHeaderIcon(systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share")
                }

                if let onEdit {
                    BrandHeaderIconButton(
                        systemImage: "pencil",
                        accessibilityLabel: "Edit",
                        action: onEdit
                    )
                }

                menu
            }

            thumbnail

            VStack(spacing: 4) {
                Text(verbatim: product.name)
                    .font(.inter(.bold, size: 20))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(verbatim: subtitle)
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .brandHeaderBackground()
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = product.imageUrls?.first, !url.isEmpty {
            RemoteImageView(imageUrl: url, width: 104, height: 104, cornerRadius: 28)
        } else {
            let tint = CategoryStyle.tint(for: mainCategory)
            Image(systemName: CategoryStyle.icon(for: mainCategory))
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 104, height: 104)
                .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }
}
