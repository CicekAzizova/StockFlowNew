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
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.inter(.medium, size: 14))
                .foregroundStyle(.textPrimary)

            Button {
                isPresented = true
            } label: {
                HStack {
                    Text(selectedName ?? "Select category")
                        .font(.inter(.regular, size: 16))
                        .foregroundStyle(selected == nil ? Color.textSecondary : Color.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(.border)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .task { await catalogStore.loadIfNeeded() }
        .sheet(isPresented: $isPresented) { selectionSheet }
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
