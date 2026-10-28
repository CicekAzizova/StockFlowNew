//
//  AppButtonView.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//

import SwiftUI

struct AppButtonView: View {

    let title: LocalizedStringKey
    var isLoading: Bool = false
    var background: Color
    var action: () -> Void
    

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.inter(.bold, size: 16))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(isLoading)
    }
}
