//
//  PINDotsView.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//
import SwiftUI

struct PINDotsView: View {
    let filledCount: Int
    let total: Int = 4
    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < filledCount ? Color.brandTeal : Color.clear)
                    .overlay(
                        Circle().stroke(
                            index < filledCount ? Color.brandTeal : Color.gray.opacity(0.5),
                            lineWidth: 1.5
                        )
                    )
                    .frame(width: 18, height: 18)
            }
        }
        .animation(.easeOut(duration: 0.15), value: filledCount)
    }
}
#Preview {
    PINDotsView(filledCount: 2)
}
