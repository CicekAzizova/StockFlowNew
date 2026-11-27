//
//  ProductFilterSheet.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

/// Kateqoriya, satış vəziyyəti və sıralama. "Göstər" basılana qədər siyahı dəyişmir.
struct ProductFilterSheet: View {

    /// Mağazanın seçdiyi əsas kateqoriyalar ("food", "home" kimi kodlar).
    let mainCategories: [String]
    let onApply: (ProductFilter) -> Void

    @State private var draft: ProductFilter
    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    init(filter: ProductFilter, mainCategories: [String], onApply: @escaping (ProductFilter) -> Void) {
        _draft = State(initialValue: filter)
        self.mainCategories = mainCategories
        self.onApply = onApply
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if !categories.isEmpty {
                        categorySection
                    }
                    saleSection
                    sortSection
                }
                .padding(16)
            }

            applyButton
        }
        .background(Color.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task { await catalogStore.loadIfNeeded() }
    }

    private var categories: [CatalogCategory] {
        catalogStore.categories(for: mainCategories)
    }

    // MARK: - Başlıq

    private var header: some View {
        HStack {
            Text("Filter")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button("Reset") { draft = ProductFilter() }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandTeal)
        }
        .padding(16)
    }

    // MARK: - Bölmələr

    private var categorySection: some View {
        section(title: "Category") {
            chip(title: Text("All"), isSelected: draft.subcategory == nil) {
                draft.subcategory = nil
            }

            ForEach(categories) { category in
                chip(
                    title: Text(verbatim: category.names.value(for: languageManager.language)),
                    isSelected: draft.subcategory == category.code
                ) {
                    draft.subcategory = category.code
                }
            }
        }
    }

    private var saleSection: some View {
        section(title: "Status") {
            chip(title: Text("All"), isSelected: draft.forSale == nil) {
                draft.forSale = nil
            }
            chip(title: Text("On sale"), isSelected: draft.forSale == true) {
                draft.forSale = true
            }
            chip(title: Text("Not for sale"), isSelected: draft.forSale == false) {
                draft.forSale = false
            }
        }
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sort")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textSecondary)

            VStack(spacing: 0) {
                ForEach(ProductSort.allCases, id: \.self) { sort in
                    Button {
                        draft.sort = sort
                    } label: {
                        HStack {
                            Text(sort.title)
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            if draft.sort == sort {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.brandGreen)
                            }
                        }
                        .font(.subheadline)
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(.plain)

                    if sort != ProductSort.allCases.last {
                        Divider()
                    }
                }
            }
            .brandCard()
        }
    }

    // MARK: - Kiçik hissələr

    private func section<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    content()
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func chip(title: Text, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                }
                title
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? Color.brandDark : Color.textSecondary)
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandGreen.opacity(0.15) : Color.surface, in: Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.brandGreen : .clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private var applyButton: some View {
        Button {
            onApply(draft)
            dismiss()
        } label: {
            Text("Show products")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.brandDark, .brandGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
