//
//  EditProfileView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

enum EditProfileFocusedField {
    case name, surname, phone
}

struct EditProfileView: View {

    let viewModel: ProfileViewModel

    @State private var name: String
    @State private var surname: String
    @State private var phone: String

    @State private var nameError: String?
    @State private var phoneError: String?
    @State private var errorMessage: String?
    @State private var isSaving = false

    @FocusState private var focusedField: EditProfileFocusedField?
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ProfileViewModel, user: User) {
        self.viewModel = viewModel
        _name = State(initialValue: user.name)
        _surname = State(initialValue: user.surname ?? "")
        _phone = State(initialValue: user.phone ?? "")
    }

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
            .navigationTitle("Edit Profile")
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
            AppTextFieldView(
                title: "Name",
                placeholder: "Name",
                icon: nil,
                focusedField: .name,
                errorMessage: nameError,
                textContentType: .givenName,
                submitLabel: .next,
                onSubmit: { focusedField = .surname },
                text: $name,
                focusedFieldBinding: $focusedField
            )

            AppTextFieldView(
                title: "Surname",
                placeholder: "Surname",
                icon: nil,
                focusedField: .surname,
                textContentType: .familyName,
                submitLabel: .next,
                onSubmit: { focusedField = .phone },
                text: $surname,
                focusedFieldBinding: $focusedField
            )

            AppTextFieldView(
                title: "Phone number",
                placeholder: "Phone number",
                icon: nil,
                focusedField: .phone,
                errorMessage: phoneError,
                textContentType: .telephoneNumber,
                keyboardType: .phonePad,
                submitLabel: .done,
                onSubmit: { focusedField = nil },
                text: $phone,
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
        nameError = nil
        phoneError = nil

        if name.isBlank {
            nameError = String(localized: "First name is required.")
        }

        let trimmedPhone = phone.trimmed
        if trimmedPhone.isEmpty {
            phoneError = String(localized: "Phone is required.")
        } else if trimmedPhone.range(of: #"^\+?[0-9 ()-]{6,20}$"#, options: .regularExpression) == nil {
            phoneError = String(localized: "Enter a valid phone number.")
        }

        return nameError == nil && phoneError == nil
    }

    private func save() async {
        guard !isSaving, validate() else { return }

        errorMessage = nil
        isSaving = true
        let error = await viewModel.updateProfile(name: name, surname: surname, phone: phone)
        isSaving = false

        if let error {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}
