//
//  BrandSearchField.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

/// Gradient başlıqda açılan ağ axtarış sahəsi.
struct BrandSearchField: View {

    let placeholder: LocalizedStringKey
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary.opacity(0.6))
                }
                .accessibilityLabel("Clear")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onAppear { isFocused = true }
    }
}
