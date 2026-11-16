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

    private let rows = [["1","2","3"],["4","5","6"],["7","8","9"]]
    private let keyHeight: CGFloat = 68

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
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
                        .font(.system(size: 22))
                        .foregroundStyle(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: keyHeight)
                }
            }
        }
    }

    private func digitButton(_ digit: String) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text(digit)
                .font(.inter(.bold, size: 24))
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: keyHeight)
                .background(.border)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PINPadView(onDigit: { print($0)}, onDelete: {})
}
