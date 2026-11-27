//
//  PINPadView.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//
import SwiftUI

struct PINPadView: View {

    let onDigit: (String) -> Void
    let onDelete: () -> Void
    /// Qaranlıq/qradiyent fonda ağ, açıq fonda tünd görünür.
    var onDark = true

    private let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    private let keyHeight: CGFloat = 62

    private var digitColor: Color { onDark ? .white : Color.textPrimary }
    private var keyBackground: Color { onDark ? .white.opacity(0.15) : Color.border }

    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            ForEach(rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { digit in
                        digitButton(digit)
                    }
                }
            }

            GridRow {
                Color.clear
                    .frame(height: keyHeight)

                digitButton("0")

                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(digitColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: keyHeight)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete")
            }
        }
    }

    private func digitButton(_ digit: String) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text(verbatim: digit)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(digitColor)
                .frame(maxWidth: .infinity)
                .frame(height: keyHeight)
                .background(keyBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PINPadView(onDigit: { print($0) }, onDelete: {}, onDark: false)
        .padding()
}
