//
//  WelcomePanelIllustration.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct WelcomePanelIllustration: View {

    private let barHeights: [CGFloat] = [14, 22, 16, 26, 20, 36]

    var body: some View {
        ZStack {
            salesCard
                .rotationEffect(.degrees(-3))
                .offset(x: -22, y: -90)

            lowStockCard
                .rotationEffect(.degrees(6))
                .offset(x:60, y: -2)

            scannedCard
                .rotationEffect(.degrees(-2))
                .offset(x: -14, y: 86)
        }
        .frame(height: 340)
    }

    // MARK: - Bugünkü satış

    private var salesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's sales")
                .font(.caption)
                .foregroundStyle(.gray)

            Text(verbatim: "1,245.80 USD")
                .font(.inter(.bold, size: 20))
                .foregroundStyle(Color.brandDark)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(barHeights.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index == barHeights.count - 1 ? Color.brandGreen : Color.brandTeal.opacity(0.18))
                        .frame(height: barHeights[index])
                }
            }
            .frame(height: 36, alignment: .bottom)
        }
        .padding(14)
        .frame(width: 250, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Az qalıb

    private var lowStockCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 18))
                .foregroundStyle(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Low stock")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text("Headphones · 2 pcs")
                    .font(.inter(.bold, size: 14))
                    .foregroundStyle(Color.brandDark)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 220)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Skan edildi

    private var scannedCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [Color.brandDark, Color.brandTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Scanned")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text("Watch")
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(Color.brandDark)
            }

            Spacer(minLength: 0)

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.brandGreen)
                .frame(width: 28, height: 28)
                .background(Color.brandGreen.opacity(0.15))
                .clipShape(Circle())
        }
        .padding(12)
        .frame(width: 270)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ZStack {
        Color.brandTeal.ignoresSafeArea()
        WelcomePanelIllustration()
    }
}
