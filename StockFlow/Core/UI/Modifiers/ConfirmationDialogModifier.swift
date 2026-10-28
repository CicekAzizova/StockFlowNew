//
//  ConfirmationDialogModifier.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

import SwiftUI

struct ConfirmationDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: LocalizedStringKey
    let message: LocalizedStringKey?
    let confirmTitle: LocalizedStringKey
    let role: ButtonRole?
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content.confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
            
            Button(confirmTitle, role: role) {
                onConfirm()
            }
            
            Button("Cancel", role: .cancel) {
            }
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}

extension View {
    
    func confirmationDialog(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        confirmTitle: LocalizedStringKey,
        role: ButtonRole? = .destructive,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            ConfirmationDialogModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                role: role,
                onConfirm: onConfirm
            )
        )
    }
}
