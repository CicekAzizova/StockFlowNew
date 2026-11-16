//
//  StockFlowLogo.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

/// StockFlow loqosu: iki sütun və yuxarı ox. Hamısı koddan çəkilir.
/// `isVisible` false-dan true-ya keçəndə sütunlar yüksəlir, ox yuxarı qalxır.
struct StockFlowLogo: View {

    var width: CGFloat = 130
    var isVisible = true

    // Loqo 580x470 ölçüsündə çəkilib, sonra `width`-ə görə kiçildilir.
    private let designWidth: CGFloat = 580
    private let designHeight: CGFloat = 470

    var body: some View {
        let scale = width / designWidth

        ZStack(alignment: .topLeading) {
            bar(x: 0, top: 280, opacity: 0.45, delay: 0)
            bar(x: 200, top: 160, opacity: 0.75, delay: 0.12)
            arrow
        }
        .frame(width: designWidth, height: designHeight, alignment: .topLeading)
        .scaleEffect(scale, anchor: .topLeading)
        .frame(width: designWidth * scale, height: designHeight * scale, alignment: .topLeading)
    }

    // MARK: - Sütun

    private func bar(x: CGFloat, top: CGFloat, opacity: Double, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 40, style: .continuous)
            .fill(.white.opacity(opacity))
            .frame(width: 150, height: designHeight - top)
            .scaleEffect(y: isVisible ? 1 : 0.01, anchor: .bottom)
            .offset(x: x, y: top)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay), value: isVisible)
    }

    // MARK: - Ox

    private var arrow: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
                .fill(.white)
                .frame(width: 150, height: designHeight - 150)
                .offset(x: 400, y: 150)

            ArrowHead()
                .fill(.white)
                .overlay(
                    ArrowHead()
                        .stroke(.white, style: StrokeStyle(lineWidth: 16, lineJoin: .round))
                )
                .frame(width: 210, height: 153)
                .offset(x: 370, y: 0)
        }
        .offset(y: isVisible ? 0 : 40)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.25), value: isVisible)
    }
}

// MARK: - Oxun başı (yumşaq küncləri olan üçbucaq)

private struct ArrowHead: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 8   // kənar xətt qalınlığının yarısı
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
        path.closeSubpath()
        return path
    }
}

#Preview {
    @Previewable @State var visible = false

    ZStack {
        Color.brandTeal.ignoresSafeArea()
        StockFlowLogo(width: 160, isVisible: visible)
    }
    .onTapGesture { visible.toggle() }
    .task { visible = true }
}
