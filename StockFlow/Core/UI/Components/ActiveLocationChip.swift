//
//  ActiveLocationChip.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

/// Əsas olmayan məkan seçiləndə onun adını kiçik nişan kimi göstərir.
struct ActiveLocationChip: View {

    @State private var name = ActiveLocationStore.name

    var body: some View {
        Group {
            if let name {
                Label {
                    Text(verbatim: name)
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                }
                .font(.inter(.bold, size: 12))
                .foregroundStyle(Color.brandTeal)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.brandTeal.opacity(0.12), in: Capsule())
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .activeLocationChanged)) { _ in
            name = ActiveLocationStore.name
        }
    }
}
