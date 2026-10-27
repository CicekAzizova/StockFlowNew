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
                    .fill(index < filledCount ? Color.primaryBlue : Color.clear)
                    .overlay(Circle().stroke(Color.primaryBlue, lineWidth: 1.5))
                    .frame(width: 16, height: 16)
                
            }
        }
    }
}
#Preview {
    PINDotsView(filledCount: 2)
}
