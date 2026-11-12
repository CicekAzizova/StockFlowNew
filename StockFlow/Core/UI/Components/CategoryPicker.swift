//
//  CategoryPicker.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import SwiftUI

struct CategoryPicker: View {

    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager

    @Binding var selected: [String]

    @State private var isPresented = false
    @State private var initialSelection: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.inter(.medium, size: 14))
                .foregroundStyle(.textPrimary)

            Button {
                initialSelection = selected
                isPresented = true
            } label: {
                HStack {
                    Text(summary)
                        .font(.inter(.regular, size: 16))
                        .foregroundStyle(selected.isEmpty ? Color.textSecondary : Color.textPrimary)
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
        .sheet(isPresented: $isPresented) {
            CategorySelectionSheet(selected: $selected, initial: initialSelection) { nil }
        }
    }

    private var summary: String {
        let names = selected.compactMap {
            catalogStore.category(code: $0)?.names.value(for: languageManager.language)
        }
        guard let first = names.first else { return "Select categories" }
        return names.count == 1 ? first : "\(first) +\(names.count - 1)"
    }
}
