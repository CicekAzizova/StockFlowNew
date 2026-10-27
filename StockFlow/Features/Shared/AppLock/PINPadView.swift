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
    
    private let keySize: CGFloat = 90
    
    var body: some View {
        VStack(spacing: 22) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 22) {
                    ForEach(row, id: \.self) { digit in
                        digitButton(digit)
                    }
                }
            }
            
            HStack(spacing: 22) {
                Color.clear.frame(width: keySize, height: keySize)
                digitButton("0")
                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.inter(.regular, size: 28))
                        .frame(width: keySize, height: keySize)
                }
            }
        }
    }
    
    private func digitButton(_ digit: String) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text(digit)
                .font(.inter(.bold, size: 28))
                .frame(width: keySize, height: keySize)
                .background(Color.primaryBlue.opacity(0.08))
                .clipShape(Circle())
        }
    }
}

#Preview {
    PINPadView(onDigit: { print($0)}, onDelete: {})
}
