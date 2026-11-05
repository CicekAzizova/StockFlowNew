//
//  BrandCard.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

extension View {
    /// Gradient üzərində duran ağ kart: boşluq, künc, kölgə.
    func brandCard() -> some View {
        self
            .padding(14)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
    }
}
