//
//  AppSecureFieldView.swift
//  StockFlow
//
//  Created by Cicek on 22.09.26.
//

import SwiftUI

struct AppSecureFieldView<FocusedField: Hashable>: View {
    
    var title: LocalizedStringKey = "Password"
    let placeholder: LocalizedStringKey
    let focusedField: FocusedField?
    var errorMessage: String? = nil
    var textContentType: UITextContentType = .password
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil
    
    var accessibilityID: String = ""
    
    @Binding var text: String
    
    var focusedFieldBinding: FocusState<FocusedField?>.Binding
    
    @State private var isAppear = false
    
    var body: some View {
        Section(title) {
            
            HStack(spacing: 8) {
                
                Group {
                    if isAppear {
                        TextField(placeholder, text: $text)
                            .accessibilityIdentifier(accessibilityID)
                    } else {
                        SecureField(placeholder, text: $text)
                            .accessibilityIdentifier(accessibilityID)
                    }
                }
                .focused(
                    focusedFieldBinding,
                    equals: focusedField
                )
                .textContentType(textContentType)             .submitLabel(submitLabel)
                .onSubmit {
                    onSubmit?()
                }
                .foregroundStyle(.textPrimary)
                
                Button {
                    isAppear.toggle()
                } label: {
                    Image(
                        systemName: isAppear
                        ? "eye.slash"
                        : "eye"
                    )
                    .foregroundStyle(.icon)
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
