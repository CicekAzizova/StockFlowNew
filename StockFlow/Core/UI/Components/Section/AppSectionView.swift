//
//  AppSectionView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

/// Başlıqlı ağ qrup. Sətirlər arasında bölücü avtomatik qoyulur.
struct AppSectionView<Content: View>: View {

    private let title: LocalizedStringKey?
    private let content: Content

    init(_ title: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 0) {
                Group(subviews: content) { subviews in
                    ForEach(subviews) { subview in
                        subview

                        if subview.id != subviews.last?.id {
                            Divider()
                                .padding(.leading, 54)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.border, lineWidth: 1)
            }
        }
    }
}
