//
//  BrandScreenHeader.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

/// Gradient üzərində ekran başlığı: (istəyə bağlı) geri düyməsi, üst yazı, başlıq, sağda düymə(lər).
struct BrandScreenHeader<Trailing: View>: View {

    let title: LocalizedStringKey
    var subtitle: String? = nil
    var showsBackButton = false
    @ViewBuilder var trailing: Trailing

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            if showsBackButton {
                BrandHeaderIconButton(
                    systemImage: "chevron.left",
                    accessibilityLabel: "Back"
                ) {
                    dismiss()
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                if let subtitle {
                    Text(verbatim: subtitle)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

extension BrandScreenHeader where Trailing == EmptyView {
    init(title: LocalizedStringKey, subtitle: String? = nil, showsBackButton: Bool = false) {
        self.init(title: title, subtitle: subtitle, showsBackButton: showsBackButton) {
            EmptyView()
        }
    }
}
