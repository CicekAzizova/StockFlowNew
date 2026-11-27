//
//  PINDotsView.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//
import SwiftUI

struct PINDotsView: View {
    let filledCount: Int
    var total: Int = 4
    /// Dolu nöqtələrin rəngi: normalda ağ, səhvdə qırmızı, düzgündə yaşıl.
    var tint: Color = .white

    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < filledCount ? tint : Color.clear)
                    .overlay(
                        Circle().stroke(
                            index < filledCount ? tint : Color.white.opacity(0.45),
                            lineWidth: 1.5
                        )
                    )
                    .frame(width: 18, height: 18)
            }
        }
        .animation(.easeOut(duration: 0.15), value: filledCount)
        .animation(.easeOut(duration: 0.2), value: tint)
    }
}
