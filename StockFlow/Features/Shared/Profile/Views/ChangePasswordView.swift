//
//  ChangePasswordView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//
import SwiftUI

enum ChangePasswordFocusedField {
    case current, new, confirm
}

struct ChangePasswordView: View {

    let viewModel: ProfileViewModel

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var currentError: String?
    @State private var newError: String?
    @State private var confirmError: String?
    @State private var errorMessage: String?
    @State private var isSaving = false

    @FocusState private var focusedField: ChangePasswordFocusedField?
    @Environment(\.dismiss) private var dismiss

    private let minPasswordLength = 6

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        form

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        saveButton
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .interactiveDismissDisabled(isSaving)
    }

    // MARK: - Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppSecureFieldView(
                title: "Current password",
                placeholder: "Current password",
                focusedField: .current,
                errorMessage: currentError,
                textContentType: .password,
                submitLabel: .next,
                onSubmit: { focusedField = .new },
                text: $currentPassword,
                focusedFieldBinding: $focusedField
            )

            AppSecureFieldView(
                title: "New password",
                placeholder: "New password",
                focusedField: .new,
                errorMessage: newError,
                textContentType: .newPassword,
                submitLabel: .next,
                onSubmit: { focusedField = .confirm },
                text: $newPassword,
                focusedFieldBinding: $focusedField
            )

            AppSecureFieldView(
                title: "Confirm new password",
                placeholder: "Confirm new password",
                focusedField: .confirm,
                errorMessage: confirmError,
                textContentType: .newPassword,
                submitLabel: .done,
                onSubmit: { Task { await save() } },
                text: $confirmPassword,
                focusedFieldBinding: $focusedField
            )
        }
    }

    private var saveButton: some View {
        AppButtonView(
            title: "Save Changes",
            isLoading: isSaving,
            background: .brandTeal
        ) {
            Task { await save() }
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func validate() -> Bool {
        currentError = nil
        newError = nil
        confirmError = nil

        if currentPassword.isEmpty {
            currentError = String(localized: "Current password is required.")
        }

        if newPassword.count < minPasswordLength {
            newError = String(localized: "Password must contain at least 6 characters.")
        } else if newPassword == currentPassword {
            newError = String(localized: "New password must be different from the current one.")
        }

        if confirmPassword != newPassword {
            confirmError = String(localized: "Passwords do not match.")
        }

        return currentError == nil && newError == nil && confirmError == nil
    }

    private func save() async {
        guard !isSaving, validate() else { return }

        errorMessage = nil
        isSaving = true
        let error = await viewModel.changePassword(current: currentPassword, new: newPassword)
        isSaving = false

        if let error {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}
