//
//  BrandHeaderIconButton.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

/// Gradient başlıqdakı şəffaf ağ kvadrat ikon (yalnız görünüş).
struct BrandHeaderIcon: View {

    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Eyni ikon düymə kimi.
struct BrandHeaderIconButton: View {

    let systemImage: String
    let accessibilityLabel: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BrandHeaderIcon(systemImage: systemImage)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
