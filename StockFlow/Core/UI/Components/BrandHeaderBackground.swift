//
//  BrandHeaderBackground.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//
import SwiftUI

/// Brend gradient başlıq fonu.
/// `height` verilməsə, fon yerləşdiyi blokun hündürlüyünə uyğunlaşır.
struct BrandHeaderBackground: View {

    var height: CGFloat? = nil

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: .brandDark, location: 0),
                .init(color: .brandTeal, location: 0.6),
                .init(color: .brandGreen, location: 1)
            ],
            startPoint: UnitPoint(x: 0.14, y: -0.18),
            endPoint: UnitPoint(x: 0.86, y: 1.18)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 220, height: 220)
                .offset(x: 60, y: -40)
        }
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32
            )
        )
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
    }
}

extension View {
    /// Bloku gradient başlığın üstünə qoyur: fon blokun ölçüsünə uyğunlaşır.
    func brandHeaderBackground() -> some View {
        background(alignment: .top) {
            BrandHeaderBackground()
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        Text("Header")
            .foregroundStyle(.white)
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity)
            .brandHeaderBackground()

        Spacer()
    }
}
