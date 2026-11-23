//
//  ReportMetricCard.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Böyük rəqəm kartı: Gəlir və ya Qazanc. Altında əvvəlki dövrlə müqayisə.
struct ReportMetricCard: View {

    let title: LocalizedStringKey
    let value: String
    /// Faiz fərqi. nil olsa, həb göstərilmir.
    let change: Double?
    var tint: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 4)

                ReportChangePill(change: change)
            }

            Text(verbatim: value)
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandCard()
    }

    @ViewBuilder
    private var changeLabel: some View {
        if let change {
            let isUp = change >= 0
            HStack(spacing: 4) {
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                Text(verbatim: "\(Int(abs(change).rounded()))%")
                Text("vs previous")
                    .foregroundStyle(.secondary)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isUp ? Color.brandGreen : Color.red)
        } else {
            Text(verbatim: " ")
                .font(.caption)
        }
    }
}
