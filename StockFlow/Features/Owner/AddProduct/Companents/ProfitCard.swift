//
//  ProfitCard.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// "Hər satışdan qazanc 0.70 · marja 58%" kartı. Mənfi olanda qırmızı olur.
struct ProfitCard: View {

    let profit: Double
    let margin: Double

    private var isLoss: Bool { profit < 0 }
    private var tint: Color { isLoss ? .error : .brandTeal }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isLoss ? "arrow.down.right" : "receipt")
                .foregroundStyle(tint)

            HStack(spacing: 4) {
                Text("Profit per sale")
                Text(verbatim: profit.asCurrency).bold()
                Text(verbatim: "·")
                Text("margin")
                Text(verbatim: "\(Int(margin.rounded()))%").bold()
            }
            .font(.inter(.regular, size: 14))
            .foregroundStyle(tint)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
