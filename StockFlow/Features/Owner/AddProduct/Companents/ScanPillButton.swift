//
//  ScanPillButton.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Barkod sahəsinin içindəki "Skan" düyməsi.
struct ScanPillButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Scan", systemImage: "barcode.viewfinder")
                .font(.inter(.bold, size: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(
                    LinearGradient(
                        colors: [.brandDark, .brandTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}
