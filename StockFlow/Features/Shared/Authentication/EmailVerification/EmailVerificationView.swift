//
//  EmailVerificationView.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct EmailVerificationView: View {

    @State var viewModel: EmailVerificationViewModel
    let onSkip: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("We sent a 6-digit code to")
                                .font(.inter(.regular, size: 15))
                                .foregroundStyle(.textSecondary)
                            Text(verbatim: " \(viewModel.email)")
                                .font(.inter(.bold, size: 15))
                                .foregroundStyle(.textPrimary)
                        }

                        CodeInputView(
                            code: $viewModel.code,
                            length: EmailVerificationViewModel.codeLength,
                            isDisabled: viewModel.isVerifying
                        )

                        if let message = viewModel.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        resendRow
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
        }
        .task {
            await viewModel.runCooldown()
        }
        .onChange(of: viewModel.code) { _, newValue in
            if newValue.count == EmailVerificationViewModel.codeLength {
                Task { await viewModel.verify() }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            BrandHeaderIcon(systemImage: "envelope.fill")

            VStack(alignment: .leading, spacing: 2) {
                Text("One last step")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)

                Text("Verify your email")
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

    // MARK: - Resend

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
            } else if viewModel.isResending {
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
        VStack(spacing: 12) {
            AppButtonView(
                title: "Verify",
                isLoading: viewModel.isVerifying,
                background: .brandPrimary
            ) {
                Task { await viewModel.verify() }
            }

            HStack(spacing: 24) {
                Button("Skip for now", action: onSkip)
                Button("Sign out", action: onSignOut)
            }
            .font(.inter(.regular, size: 14))
            .foregroundStyle(.textSecondary)
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.background)
    }
}
