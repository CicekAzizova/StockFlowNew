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
    
    var body: some View {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                content
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            }
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
                    header
                    form
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            
            createStoreButton
        }
    }

    // MARK: - Header

    var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(.roleIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.top, 12)
            Text(
                "Your account is automatically assigned the OWNER role with full management access."
            )
            .font(.inter(.regular, size: 15))
            .foregroundStyle(.textSecondary)
            .padding(.bottom, 32)
        }
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
            title: "Create Store",
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

