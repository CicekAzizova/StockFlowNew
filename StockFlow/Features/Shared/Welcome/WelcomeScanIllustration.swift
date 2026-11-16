//
//  WelcomeScanIllustration.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct WelcomeScanIllustration: View {

    private let barWidths: [CGFloat] = [2, 1, 3, 1, 2, 4, 1, 2, 1, 3, 2, 1, 4, 1, 2, 3, 1, 1, 3, 2, 1, 2, 4, 1, 3, 1, 2]

    var body: some View {
        ZStack {
            scanner
                .offset(y: -90)

            foundChip
                .offset(x: -110, y: -12)

            productCard
                .offset(y: 61)

            cartChip
                .offset(x: 55, y: 122)
        }
        .frame(height: 340)
    }

    // MARK: - Skaner

    private var scanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.08))

            ScannerCorners()
                .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

            VStack(spacing: 4) {
                barcode
                Text(verbatim: "4760001020201")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(10)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Rectangle()
                .fill(Color.brandGreen)
                .frame(height: 2)
                .shadow(color: Color.brandGreen, radius: 6)
                .padding(.horizontal, 22)
        }
        .frame(width: 250, height: 160)
    }

    private var barcode: some View {
        HStack(spacing: 2.5) {
            ForEach(barWidths.indices, id: \.self) { index in
                Rectangle()
                    .fill(.black)
                    .frame(width: barWidths[index] * 1.6)
            }
        }
        .frame(height: 62)
    }

    // MARK: - "Tapıldı" nişanı

    private var foundChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle")
            Text("Found")
        }
        .font(.inter(.bold, size: 13))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.brandGreen)
        .clipShape(Capsule())
        .rotationEffect(.degrees(-4))
    }

    // MARK: - Məhsul kartı

    private var productCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "applewatch")
                .font(.system(size: 20))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 44, height: 44)
                .background(Color.brandTeal.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Watch")
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(Color.brandDark)
                Text(verbatim: "WT-0201 · 124")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(verbatim: "49.90")
                    .font(.inter(.bold, size: 16))
                    .foregroundStyle(Color.brandDark)
                Text(verbatim: "USD")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
        .padding(12)
        .frame(width: 290)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Səbət nişanı

    private var cartChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "cart")
            Text("Added to cart · 3")
        }
        .font(.inter(.bold, size: 13))
        .foregroundStyle(Color.brandDark)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white)
        .clipShape(Capsule())
        .rotationEffect(.degrees(3))
    }
}

// MARK: - Skanerin künc xətləri

private struct ScannerCorners: Shape {
    func path(in rect: CGRect) -> Path {
        let length: CGFloat = 36
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}

#Preview {
    ZStack {
        Color.brandTeal.ignoresSafeArea()
        WelcomeScanIllustration()
    }
}
