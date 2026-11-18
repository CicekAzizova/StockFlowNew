//
//  AddProductStepBar.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Addım zolaqları: "Basic info" və "Price & stock". Gradient üzərində göstərilir.
struct AddProductStepBar: View {

    let step: Int

    private let titles: [LocalizedStringKey] = ["Basic info", "Price & stock"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...2, id: \.self) { index in
                VStack(alignment: .leading, spacing: 6) {
                    Capsule()
                        .fill(.white.opacity(index <= step ? 1 : 0.3))
                        .frame(height: 4)
                    Text(titles[index - 1])
                        .font(.caption.weight(index == step ? .bold : .regular))
                        .foregroundStyle(.white.opacity(index == step ? 1 : 0.7))
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
