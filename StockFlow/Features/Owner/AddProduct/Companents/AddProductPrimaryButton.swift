//
//  AddProductPrimaryButton.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Alt hissədəki böyük gradient düymə: "Davam et →" və "Məhsulu yarat ✓".
struct AddProductPrimaryButton: View {

    let title: LocalizedStringKey
    let systemImage: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 8) {
                        if systemImage == "arrow.right" {
                            Text(title)
                            Image(systemName: systemImage)
                        } else {
                            Image(systemName: systemImage)
                            Text(title)
                        }
                    }
                    .font(.inter(.bold, size: 17))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [.brandDark, .brandGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
        }
        .disabled(isLoading)
    }
}
