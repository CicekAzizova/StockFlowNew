//
//  CodeInputView.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct CodeInputView: View {

    @Binding var code: String
    let length: Int
    var isDisabled = false

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Real yazı sahəsi: görünmür, amma klaviaturanı o açır.
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01)
                .disabled(isDisabled)
                .onChange(of: code) { _, newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(length))
                    if digits != newValue {
                        code = digits
                    }
                }

            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { index in
                    box(at: index)
                }
            }
            .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .onAppear { isFocused = true }
    }

    private func box(at index: Int) -> some View {
        let characters = Array(code)
        let isCurrent = isFocused && index == code.count

        return Text(index < characters.count ? String(characters[index]) : "")
            .font(.inter(.bold, size: 22))
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.border)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCurrent ? Color.brandPrimary : Color.gray.opacity(0.4),
                        lineWidth: isCurrent ? 2 : 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    @Previewable @State var code = "12"
    CodeInputView(code: $code, length: 6)
        .padding(24)
}
