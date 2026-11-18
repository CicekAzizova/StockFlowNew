//
//  ProductFormField.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Add-product ekranının sahəsi: başlıq yuxarıda, ağ yuvarlaq sahə, fokusda yaşıl çərçivə.
struct ProductFormField<Focus: Hashable, Trailing: View>: View {

    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let focus: Focus
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)? = nil
    @Binding var text: String
    var focusBinding: FocusState<Focus?>.Binding
    @ViewBuilder var trailing: Trailing

    private var isFocused: Bool { focusBinding.wrappedValue == focus }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textSecondary)
                .padding(.leading, 4)

            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .focused(focusBinding, equals: focus)
                    .keyboardType(keyboard)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
                    .font(.inter(.regular, size: 16))
                    .foregroundStyle(.textPrimary)

                trailing
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isFocused ? Color.brandTeal : Color.gray.opacity(0.25),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            }
            .shadow(color: isFocused ? Color.brandTeal.opacity(0.25) : .clear, radius: 6)
        }
    }
}

extension ProductFormField where Trailing == EmptyView {
    init(
        title: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        focus: Focus,
        keyboard: UIKeyboardType = .default,
        submitLabel: SubmitLabel = .next,
        onSubmit: (() -> Void)? = nil,
        text: Binding<String>,
        focusBinding: FocusState<Focus?>.Binding
    ) {
        self.init(
            title: title,
            placeholder: placeholder,
            focus: focus,
            keyboard: keyboard,
            submitLabel: submitLabel,
            onSubmit: onSubmit,
            text: text,
            focusBinding: focusBinding
        ) {
            EmptyView()
        }
    }
}
