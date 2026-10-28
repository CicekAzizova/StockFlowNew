//
//  AppTextFieldView.swift
//  StockFlow
//
//  Created by Cicek on 22.09.26.
//

import SwiftUI

struct AppTextFieldView<FocusedField: Hashable>: View {

    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let icon: String?
    let focusedField: FocusedField
    
    var errorMessage: String? = nil
    var textContentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)? = nil
    var iconAction: (() -> Void)? = nil
    
    var accessibilityID: String = ""

    @Binding var text: String

    var focusedFieldBinding: FocusState<FocusedField?>.Binding

    var body: some View {
        Section(title) {
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .focused(
                        focusedFieldBinding,
                        equals: focusedField
                    )
                    .textContentType(textContentType)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
                    .foregroundStyle(.textPrimary)
                    .accessibilityIdentifier(accessibilityID)

                if let icon {
                    if let iconAction {
                        Button(action: iconAction) {
                            Image(systemName: icon)
                                .foregroundStyle(.icon)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: icon)
                            .foregroundStyle(.icon)
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.border)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedFieldBinding.wrappedValue == focusedField
                        ? Color.accentColor
                        : Color.clear,
                        lineWidth: 1.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if let errorMessage {
                Text(LocalizedStringKey(errorMessage))
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.error)
                    .padding(.leading, 4)
            }
        }
    }
}
