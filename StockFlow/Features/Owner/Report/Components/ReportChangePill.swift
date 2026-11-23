//
//  ReportChangePill.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Maketdəki kimi kiçik faiz "həb"i: ▲ 18% (yaşıl) və ya ▼ 4% (qırmızı).
struct ReportChangePill: View {

    /// nil olsa (əvvəlki dövr 0 idi), heç nə göstərilmir.
    let change: Double?

    var body: some View {
        if let change {
            let isUp = change >= 0
            let color: Color = isUp ? .brandGreen : .red

            HStack(spacing: 3) {
                Image(systemName: isUp ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                Text(verbatim: "\(Int(abs(change).rounded()))%")
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
        }
    }
}
