//
//  ForgotPasswordView.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

enum ForgotPasswordField: Hashable {
    case email, password
}

struct ForgotPasswordView: View {

    @State var viewModel: ForgotPasswordViewModel
    @FocusState private var focusedField: ForgotPasswordField?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch viewModel.step {
                        case .email:
                            emailStep
                        case .reset:
                            resetStep
                        }

                        if let message = viewModel.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task(id: viewModel.step) {
            if viewModel.step == .reset {
                await viewModel.runCooldown()
            }
        }
        .alert("Password updated", isPresented: $viewModel.didReset) {
            Button("Sign In") {
                dismiss()
            }
        } message: {
            Text("You can now sign in with your new password.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            BrandHeaderIconButton(
                systemImage: "chevron.left",
                accessibilityLabel: "Back"
            ) {
                if viewModel.step == .reset {
                    viewModel.backToEmail()
                } else {
                    dismiss()
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Password recovery")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)

                Text(viewModel.step == .email
                     ? LocalizedStringKey("Forgot password")
                     : LocalizedStringKey("Reset password"))
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

    // MARK: - Addım 1: email

    @ViewBuilder
    private var emailStep: some View {
        Text("Enter your account email and we will send you a 6-digit code.")
            .font(.inter(.regular, size: 15))
            .foregroundStyle(.textSecondary)

        AppTextFieldView(
            title: "Email",
            placeholder: "email",
            icon: "envelope",
            focusedField: ForgotPasswordField.email,
            errorMessage: viewModel.emailError,
            textContentType: .emailAddress,
            keyboardType: .emailAddress,
            submitLabel: .send,
            onSubmit: {
                Task { await viewModel.sendCode() }
            },
            text: $viewModel.email,
            focusedFieldBinding: $focusedField
        )

        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.brandTeal)
            Text("Are you a seller? Ask the store owner to set a new password for you.")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandTeal.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 8)
    }

    // MARK: - Addım 2: kod və yeni şifrə

    @ViewBuilder
    private var resetStep: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("We sent a 6-digit code to")
                .foregroundStyle(.textSecondary)

            Text(verbatim: viewModel.email)
                .fontWeight(.bold)
                .foregroundStyle(.textPrimary)
        }
        .font(.inter(.regular, size: 15))
        .frame(maxWidth: .infinity, alignment: .leading)

        CodeInputView(
            code: $viewModel.code,
            length: ForgotPasswordViewModel.codeLength,
            isDisabled: viewModel.isLoading
        )

        AppSecureFieldView(
            placeholder: "New password",
            focusedField: ForgotPasswordField.password,
            errorMessage: viewModel.passwordError,
            submitLabel: .done,
            onSubmit: {
                Task { await viewModel.resetPassword() }
            },
            text: $viewModel.newPassword,
            focusedFieldBinding: $focusedField
        )

        resendRow
    }

    private var resendRow: some View {
        HStack(spacing: 4) {
            Text("Didn't get the code?")
                .foregroundStyle(.textSecondary)

            if viewModel.canResend {
                Button("Resend") {
                    Task { await viewModel.resend() }
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.brandTeal)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Resend in \(viewModel.secondsLeft)s")
                    .foregroundStyle(.textSecondary)
            }
        }
        .font(.inter(.regular, size: 14))
    }

    // MARK: - Footer

    private var footer: some View {
        AppButtonView(
            title: viewModel.step == .email
                ? LocalizedStringKey("Send code")
                : LocalizedStringKey("Reset password"),
            isLoading: viewModel.isLoading,
            usesBrandGradient: true
        ) {
            focusedField = nil
            Task {
                switch viewModel.step {
                case .email: await viewModel.sendCode()
                case .reset: await viewModel.resetPassword()
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.background)
    }
}
