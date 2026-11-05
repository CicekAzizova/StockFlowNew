//
//  DeleteAccountModifier.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

/// Hesabı silmə axını: xəbərdarlıq + şifrə, yüklənmə göstəricisi, xəta.
/// `onDelete` şifrəni alır, uğurlu olsa `nil`, əks halda xəta mətni qaytarır.
struct DeleteAccountModifier: ViewModifier {

    @Binding var isPresented: Bool
    let onDelete: (String) async -> String?

    @State private var password = ""
    @State private var isDeleting = false
    @State private var errorMessage: String?

    func body(content: Content) -> some View {
        content
            .alert("Delete Account?", isPresented: $isPresented) {
                SecureField("Password", text: $password)

                Button("Delete", role: .destructive) {
                    Task { await deleteAccount() }
                }
                .disabled(password.isEmpty)

                Button("Cancel", role: .cancel) {
                    password = ""
                }
            } message: {
                Text("Your store, products, team and all data will be permanently deleted. This cannot be undone. Enter your password to confirm.")
            }
            .alert("Couldn't delete", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .overlay {
                if isDeleting {
                    ProgressView("Deleting...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(isDeleting)
    }

    private var errorBinding: Binding<Bool> {
        Binding {
            errorMessage != nil
        } set: { isShown in
            if !isShown { errorMessage = nil }
        }
    }

    private func deleteAccount() async {
        let enteredPassword = password
        password = ""

        isDeleting = true
        errorMessage = await onDelete(enteredPassword)
        isDeleting = false
    }
}

extension View {
    func deleteAccountAlert(
        isPresented: Binding<Bool>,
        onDelete: @escaping (String) async -> String?
    ) -> some View {
        modifier(DeleteAccountModifier(isPresented: isPresented, onDelete: onDelete))
    }
}
