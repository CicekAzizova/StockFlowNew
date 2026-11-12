//
//  LanguageMenuButton.swift
//  StockFlow
//
//  Created by Cicek on 12.11.26.
//

import SwiftUI

/// Gradient üzərində dil seçimi: qlobus, qısa kod (AZ) və ox. Basanda dillər menyusu açılır.
struct LanguageMenuButton: View {

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        @Bindable var languageManager = languageManager

        Menu {
            Picker("Language", selection: $languageManager.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                Text(verbatim: languageManager.language.shortCode)
                    .font(.footnote.weight(.bold))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.18), in: Capsule())
        }
    }
}
