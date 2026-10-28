//
//  InfoRow.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

import SwiftUI

struct InfoRow: View {
    let title: LocalizedStringKey
    private let valueContent: AnyView

    init(title: LocalizedStringKey, value: String) {
        self.title = title
        self.valueContent = AnyView(Text(value).foregroundStyle(.textPrimary))
    }

    init(title: LocalizedStringKey, localizedValue: LocalizedStringKey) {
        self.title = title
        self.valueContent = AnyView(Text(localizedValue).foregroundStyle(.textPrimary))
    }

    var body: some View {
        HStack {
            Text(title).foregroundStyle(.textSecondary)
            Spacer()
            valueContent
        }
    }
}
