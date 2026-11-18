//
//  SubcategoryPicker.swift
//  StockFlow
//
//  Created by Cicek on 12.11.26.
//
import SwiftUI

/// Məhsulun alt kateqoriyasını seçir. Yalnız mağazanın seçdiyi əsas kateqoriyalar göstərilir.
struct SubcategoryPicker: View {

    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager
    @Environment(AppStateManager.self) private var appStateManager

    @Binding var selected: String?

    @State private var isPresented = false

    private var language: AppLanguage { languageManager.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textSecondary)
                .padding(.leading, 4)

            Button {
                isPresented = true
            } label: {
                HStack(spacing: 10) {
                    if let selected {
                        Circle()
                            .fill(CategoryStyle.tint(for: mainCode(of: selected)))
                            .frame(width: 10, height: 10)
                    }
                    Text(selectedName ?? String(localized: "Select category"))
                        .font(.inter(.regular, size: 16))
                        .foregroundStyle(selected == nil ? Color.textSecondary : Color.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .task { await catalogStore.loadIfNeeded() }
        .sheet(isPresented: $isPresented) { selectionSheet }
    }

    /// "food.dairy" → "food"
    private func mainCode(of code: String) -> String {
        code.split(separator: ".").first.map(String.init) ?? ""
    }

    // MARK: - Data

    private var selectedName: String? {
        guard let selected else { return nil }
        return catalogStore.subcategory(code: selected)?.names.value(for: language)
    }

    /// Mağazanın əsas kateqoriyaları (hələ seçilməyibsə "other").
    private var groups: [CatalogCategory] {
        catalogStore.categories(for: appStateManager.user?.mainCategories ?? ["other"])
    }

    // MARK: - Sheet

    private var selectionSheet: some View {
        NavigationStack {
            List {
                Button {
                    selected = nil
                    isPresented = false
                } label: {
                    HStack {
                        Text("None")
                            .foregroundStyle(.textSecondary)
                        Spacer()
                        if selected == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }
                }

                ForEach(groups) { group in
                    Section(group.names.value(for: language)) {
                        ForEach(group.subcategories) { sub in
                            Button {
                                selected = sub.code
                                isPresented = false
                            } label: {
                                HStack {
                                    Text(sub.names.value(for: language))
                                        .foregroundStyle(.textPrimary)
                                    Spacer()
                                    if selected == sub.code {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.brandPrimary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { isPresented = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
