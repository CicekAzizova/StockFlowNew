//
//  LoginView.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//


import SwiftUI

struct LoginView: View {

    @State var viewModel: LoginViewModel

    let dependencies: AppDependencies
    let appStateManager: AppStateManager

    @FocusState private var focusedField: LoginFocusedField?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    screenHeader

                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .dismissKeyboardOnTap()
        }
    }

    // MARK: - Header

    private var screenHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                LanguageMenuButton()
            }

            StockFlowLogo(width: 40)
                .frame(width: 72, height: 72)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )

            Text("Welcome back")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Sign in to manage your store.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .brandHeaderBackground()
    }

    // MARK: - Content

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle, .loading, .error:
            loginScreen
        case .loaded:
            ProgressView()
        }
    }

    var loginScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    loginForm
                    signInButton
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)

            footer
        }
    }

    // MARK: - Login Form

    @ViewBuilder
    var loginForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppTextFieldView(
                title: "Email",
                placeholder: "email",
                icon: "envelope",
                focusedField: .email,
                errorMessage: viewModel.fieldErrors[.email],
                textContentType: .emailAddress,
                keyboardType: .emailAddress,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .password
                },
                accessibilityID: "loginEmailField",
                text: $viewModel.email,
                focusedFieldBinding: $focusedField
            )

            AppSecureFieldView(
                placeholder: "Password",
                focusedField: .password,
                errorMessage: viewModel.fieldErrors[.password],
                submitLabel: .done,
                onSubmit: {
                    Task {
                        await performLogin()
                    }
                },
                accessibilityID: "loginPasswordField",
                text: $viewModel.password,
                focusedFieldBinding: $focusedField
                
            )
            
            HStack {
                Spacer()

                NavigationLink {
                    ForgotPasswordView(
                        viewModel: dependencies.makeForgotPasswordViewModel()
                    )
                } label: {
                    Text("Forgot password?")
                        .font(.inter(.bold, size: 13))
                        .foregroundStyle(Color.brandTeal)
                }
                .accessibilityIdentifier("forgotPasswordLink")
            }
            .padding(.top, 4)

            if case .error(let message) = viewModel.state {
                ErrorMessageView(message: message)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .disabled(viewModel.state.isLoading)
    }

    var signInButton: some View {
        AppButtonView(
            title: "Sign In",
            isLoading: viewModel.state.isLoading,
            usesBrandGradient: true
        ) {
            Task {
                await performLogin()
            }
        }
        .padding(.top, 24)
    }

    // MARK: - Footer

    var footer: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(.textSecondary)

            NavigationLink {
                CreateStoreView(
                    viewModel: dependencies.makeCreateStoreViewModel(appStateManager: appStateManager)
                )
            } label: {
                Text("Create account")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandTeal)
            }
        }
        .font(.inter(.regular, size: 14))
        .padding(.bottom, 16)
        .background(Color.background)
    }

    @MainActor
    private func performLogin() async {
        await viewModel.login()
    }
}

// MARK: - Preview

#Preview("Idle State") {
    let dependencies = AppDependencies()
    let appStateManager = AppStateManager(tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository)


    LoginView(
        viewModel: dependencies.makeLoginViewModel(appStateManager: appStateManager),
        dependencies: dependencies, appStateManager: appStateManager
    )
   
}

#Preview("Error State") {
    let dependencies = AppDependencies()
    let appStateManager = AppStateManager(tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository)

    let viewModel = dependencies.makeLoginViewModel(appStateManager: appStateManager)

    viewModel.state = .error(
        "Email və ya password yanlışdır."
    )

   return LoginView(viewModel: viewModel, dependencies: dependencies, appStateManager: appStateManager)
       
}
