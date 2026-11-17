//
//  SubcategoryChips.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

struct SubcategoryChips: View {

    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager

    let mainCategories: [String]
    @Binding var selected: [String]
    let drafts: [OnboardingViewModel.CustomDraft]
    let onAddCustom: (String) -> Void
    let onRemoveCustom: (OnboardingViewModel.CustomDraft) -> Void

    @State private var newName = ""

    private var sections: [CatalogCategory] {
        catalogStore.categories.filter { mainCategories.contains($0.code) }
    }

    private var availableCodes: [String] {
        sections.flatMap(\.subcategories).map(\.code)
    }

    private var totalSelected: Int {
        selected.count + drafts.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            selectedSection
            addCustomRow
            suggestionsSection
        }
        .task {
            await catalogStore.loadIfNeeded()
            // Geri qayıdıb əsas kateqoriyanı dəyişəndə artıq aidiyyəti olmayanları təmizləyir.
            selected = selected.filter(availableCodes.contains)
        }
    }

    // MARK: - Seçilmiş (yuxarı)

    private var selectedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Selected · \(totalSelected)")
                    .font(.inter(.bold, size: 13))
                    .foregroundStyle(.textSecondary)

                Spacer()

                if totalSelected > 0 {
                    Button("Clear all") {
                        selected = []
                        drafts.forEach(onRemoveCustom)
                    }
                    .font(.inter(.bold, size: 13))
                    .foregroundStyle(Color.brandTeal)
                }
            }

            if totalSelected == 0 {
                Text("Nothing selected yet. Tap a category below.")
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(selected, id: \.self) { code in
                        selectedChip(title: name(for: code)) {
                            selected.removeAll { $0 == code }
                        }
                    }
                    ForEach(drafts) { draft in
                        selectedChip(title: draft.name) {
                            onRemoveCustom(draft)
                        }
                    }
                }
            }
        }
    }

    private func selectedChip(title: String, onRemove: @escaping () -> Void) -> some View {
        Button(action: onRemove) {
            HStack(spacing: 6) {
                Text(verbatim: title)
                    .font(.inter(.medium, size: 14))
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(Color.brandTeal)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.brandTeal.opacity(0.12))
            .overlay {
                Capsule().stroke(Color.brandTeal, lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Təkliflər (aşağı)

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sections) { category in
                let remaining = category.subcategories.filter { !selected.contains($0.code) }

                if !remaining.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(category.names.value(for: languageManager.language))
                            .font(.inter(.bold, size: 14))
                            .foregroundStyle(.textPrimary)

                        FlowLayout(spacing: 8) {
                            ForEach(remaining) { sub in
                                suggestionChip(sub)
                            }
                        }
                    }
                }
            }
        }
    }

    private func suggestionChip(_ sub: CatalogSubcategory) -> some View {
        Button {
            selected.append(sub.code)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                Text(sub.names.value(for: languageManager.language))
                    .font(.inter(.medium, size: 14))
            }
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.surface)
            .overlay {
                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Yeni kateqoriya

    private var addCustomRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .foregroundStyle(.textSecondary)
                TextField("New category name", text: $newName)
                    .font(.inter(.regular, size: 15))
                    .submitLabel(.done)
                    .onSubmit(addCustom)
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color.surface)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: addCustom) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.brandTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(newName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
        }
    }

    private func addCustom() {
        onAddCustom(newName)
        newName = ""
    }

    private func name(for code: String) -> String {
        catalogStore.subcategory(code: code)?.names.value(for: languageManager.language) ?? code
    }
}
