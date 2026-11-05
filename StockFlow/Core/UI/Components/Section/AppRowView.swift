//
//  AppRowView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

/// Siyahı sətri: rəngli ikon + mətn + sağ tərəf (ox, toggle və s.).
struct AppRowView<Trailing: View>: View {

    let icon: String
    let tint: Color
    let title: LocalizedStringKey
    var titleColor: Color = .textPrimary
    private let trailing: Trailing

    init(
        icon: String,
        tint: Color,
        title: LocalizedStringKey,
        titleColor: Color = .textPrimary,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.icon = icon
        self.tint = tint
        self.title = title
        self.titleColor = titleColor
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(titleColor)

            Spacer(minLength: 8)

            trailing
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Sağ tərəfi olmayan variant

extension AppRowView where Trailing == EmptyView {
    init(
        icon: String,
        tint: Color,
        title: LocalizedStringKey,
        titleColor: Color = .textPrimary
    ) {
        self.init(icon: icon, tint: tint, title: title, titleColor: titleColor) {
            EmptyView()
        }
    }
}

// MARK: - Ox (və istəyə görə dəyər)

struct AppRowDisclosure: View {

    var value: String?

    var body: some View {
        HStack(spacing: 8) {
            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textSecondary.opacity(0.6))
        }
    }
}
