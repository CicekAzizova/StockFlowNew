//
//  CreateStoreView.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//

import SwiftUI

struct CreateStoreView: View {

    @State var viewModel: CreateStoreViewModel
    @FocusState private var focusedField: CreateStoreFocusedField?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader

                content
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Content

    @ViewBuilder
    var content: some View {
        switch viewModel.state {

        case .idle:
            createStoreScreen

        case .loading:
            ProgressView("Creating store...")

        case .success:
            Color.clear

        case .error(let message):
            createStoreScreen
                .overlay(alignment: .top) {
                    ErrorMessageView(message: message)
                }
        }
    }

    // MARK: - Create Store Screen

    var createStoreScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    form
                    sellerNote
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()

            createStoreButton
            signInLink
        }
    }

    // MARK: - Header

    private var screenHeader: some View {
        HStack(spacing: 12) {
            BrandHeaderIconButton(
                systemImage: "chevron.left",
                accessibilityLabel: "Back"
            ) {
                dismiss()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("As a store owner")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)

                Text("Create account")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            LanguageMenuButton()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 20)
        .brandHeaderBackground()
    }

    // MARK: - Seller note

    private var sellerNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.brandTeal)
            Text("Are you a seller? The store owner creates your account, just sign in.")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandTeal.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 16)
    }

    // MARK: - Sign in link

    private var signInLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(.textSecondary)
            Button("Sign in") { dismiss() }
                .fontWeight(.bold)
                .foregroundStyle(Color.brandTeal)
        }
        .font(.inter(.regular, size: 14))
        .padding(.bottom, 16)
        .background(Color.background)
    }

    // MARK: - Form

    @ViewBuilder
    var form: some View {

        AppTextFieldView(
            title: "Name",
            placeholder: "Your name",
            icon: nil,
            focusedField: .name,
            errorMessage: viewModel.fieldErrors[.name],
            submitLabel: .next,
            onSubmit: {
                focusedField = .surname
            },
            text: $viewModel.name,
            focusedFieldBinding: $focusedField
        )

        AppTextFieldView(
            title: "Surname",
            placeholder: "Your surname",
            icon: nil,
            focusedField: .surname,
            errorMessage: viewModel.fieldErrors[.surname],
            submitLabel: .next,
            onSubmit: {
                focusedField = .email
            },
            text: $viewModel.surname,
            focusedFieldBinding: $focusedField
        )
        
        AppTextFieldView(
            title: "Email",
            placeholder: "you@example.com",
            icon: nil,
            focusedField: .email,
            errorMessage: viewModel.fieldErrors[.email],
            textContentType: .emailAddress,
            keyboardType: .emailAddress,
            submitLabel: .next,
            onSubmit: {
                focusedField = .phone
            },
            text: $viewModel.email,
            focusedFieldBinding: $focusedField
        )
        
        AppTextFieldView(
            title: "Phone",
            placeholder: "+994",
            icon: nil,
            focusedField: .phone,
            errorMessage: viewModel.fieldErrors[.phone],
            keyboardType: .phonePad,
            submitLabel: .next,
            onSubmit: {
                focusedField = .password
            },
            text: $viewModel.phone,
            focusedFieldBinding: $focusedField
        )


        AppSecureFieldView(
            placeholder: "Password",
            focusedField: .password,
            errorMessage: viewModel.fieldErrors[.password],
            submitLabel: .next,
            onSubmit: {
                focusedField = nil
            },
            text: $viewModel.password,
            focusedFieldBinding: $focusedField
        )
    }
    
    

    // MARK: - Create Store Button

    var createStoreButton: some View {
        AppButtonView(
            title: "Create account",
            isLoading: viewModel.state.isLoading, background: .brandPrimary
        ) {
            Task {
                await viewModel.createStore()
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.background)
    }
}

