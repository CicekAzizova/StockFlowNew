//
//  ScanTabButton.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Tab barın ortasındakı skan düyməsi (yumru kvadrat, brend gradienti).
struct ScanTabButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(
                        colors: [.brandDark, .brandGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: Color.brandDark.opacity(0.3), radius: 8, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scan Product")
    }
}
