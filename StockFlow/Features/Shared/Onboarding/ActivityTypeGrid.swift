//
//  ActivityTypeGrid.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct ActivityTypeGrid: View {

    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager

    @Binding var selected: [String]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Business type")
                .font(.inter(.medium, size: 14))
                .foregroundStyle(.textPrimary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(catalogStore.categories) { category in
                    tile(for: category)
                }
            }
        }
        .task { await catalogStore.loadIfNeeded() }
    }

    private func tile(for category: CatalogCategory) -> some View {
        let isSelected = selected.contains(category.code)
        let tint = CategoryStyle.tint(for: category.code)

        return Button {
            toggle(category.code)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: CategoryStyle.icon(for: category.code))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(tint)
                    .frame(width: 30, height: 30)
                    .background(tint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(category.names.value(for: languageManager.language))
                    .font(.inter(.medium, size: 11))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 14).fill(Color.surface)
                if isSelected {
                    RoundedRectangle(cornerRadius: 14).fill(Color.brandTeal.opacity(0.08))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.brandTeal : Color.gray.opacity(0.25),
                            lineWidth: isSelected ? 1.5 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.brandGreen)
                        .background(Circle().fill(.white))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private static func tint(for code: String) -> Color {
        switch code {
        case "food": Color.brandGreen
        case "clothing": Color.purple
        case "footwear_bags": Color.indigo
        case "electronics": Color.blue
        case "home": Color.teal
        case "beauty": Color.pink
        case "kids": Color.orange
        case "books": Color(red: 0.85, green: 0.45, blue: 0.2)
        case "auto": Color.red
        case "construction": Color.yellow
        case "sports": Color.mint
        default: Color.gray
        }
    }

    private func toggle(_ code: String) {
        if let index = selected.firstIndex(of: code) {
            selected.remove(at: index)
        } else {
            selected.append(code)
        }
    }

    private static func icon(for code: String) -> String {
        switch code {
        case "food": "cart"
        case "clothing": "tshirt"
        case "footwear_bags": "bag"
        case "electronics": "iphone"
        case "home": "house"
        case "beauty": "sparkles"
        case "kids": "teddybear"
        case "books": "book"
        case "auto": "car"
        case "construction": "hammer"
        case "sports": "figure.run"
        default: "ellipsis"
        }
    }
}
