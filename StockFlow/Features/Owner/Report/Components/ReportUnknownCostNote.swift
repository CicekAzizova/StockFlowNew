//
//  ReportUnknownCostNote.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Alış qiyməti məlum olmayan satışlar barədə xəbərdarlıq.
struct ReportUnknownCostNote: View {

    let amount: Double

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.warning)

            Text("\(amount.asCurrency) of sales have no cost price, so they are not included in profit.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.warning.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}
