//
//  LowStockCard.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// "Az stok həddi": bu saydan aşağı düşəndə bildiriş.
struct LowStockCard: View {

    @Binding var value: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 18))
                .foregroundStyle(Color.orange)
                .frame(width: 40, height: 40)
                .background(Color.orange.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Low stock limit")
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.textPrimary)
                Text("Notify when stock falls to this level")
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            StockStepper(value: $value)
        }
        .padding(12)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
