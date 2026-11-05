//
//  ProfileBadge.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI


struct ProfileBadge: View {

    private let label: Text
    private let systemImage: String?

    init(_ key: LocalizedStringKey, systemImage: String? = nil) {
        self.label = Text(key)
        self.systemImage = systemImage
    }

    init(verbatim text: String, systemImage: String? = nil) {
        self.label = Text(verbatim: text)
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .bold))
            }

            label
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .fixedSize()
        }
        .foregroundStyle(Color.brandTeal)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.brandTeal.opacity(0.10))
        .clipShape(Capsule())
    }
}
