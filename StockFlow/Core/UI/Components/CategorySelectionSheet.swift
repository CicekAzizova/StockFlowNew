//
//  CategorySelectionSheet.swift
//  StockFlow
//
//  Created by Cicek on 12.11.26.
//

import SwiftUI

/// Əsas kateqoriyaları seçmək üçün ortaq sheet (maksimum 5).
/// Seçim `selected` binding-inə yazılır, `onSave` yalnız "indi saxla" deməkdir.
struct CategorySelectionSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager

    @Binding var selected: [String]
    /// Sheet açılan andakı seçim: Cancel bunu geri qaytarır, Save-in aktivliyi bununla müqayisə olunur.
    let initial: [String]
    let onSave: () async -> String?

    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List(catalogStore.categories) { category in
                let isSelected = selected.contains(category.code)

                Button {
                    toggle(category.code)
                } label: {
                    HStack {
                        Text(category.names.value(for: languageManager.language))
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Categories (\(selected.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selected = initial
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaving || selected.isEmpty || selected == initial)
                }
            }
            .task { await catalogStore.loadIfNeeded() }
            .alert(
                "Could not save categories",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func toggle(_ code: String) {
        if let index = selected.firstIndex(of: code) {
            selected.remove(at: index)
        } else {
            selected.append(code)
        }
    }

    private func save() {
        isSaving = true
        Task {
            if let error = await onSave() {
                errorMessage = error
            } else {
                dismiss()
            }
            isSaving = false
        }
    }
}
