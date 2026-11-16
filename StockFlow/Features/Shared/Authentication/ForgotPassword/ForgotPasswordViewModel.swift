//
//  ForgotPasswordViewModel.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ForgotPasswordViewModel {

    enum Step {
        case email
        case reset
    }

    static let codeLength = 6
    private static let cooldownSeconds = 60

    var step: Step = .email

    var email = ""
    var code = ""
    var newPassword = ""

    var isLoading = false
    var emailError: String?
    var passwordError: String?
    var errorMessage: String?
    var secondsLeft = 0
    var didReset = false

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canResend: Bool {
        secondsLeft == 0 && !isLoading
    }

    // MARK: - Addım 1: kod göndər

    func sendCode() async {
        emailError = nil
        errorMessage = nil

        guard !trimmedEmail.isEmpty else {
            emailError = "Email is required."
            return
        }
        guard trimmedEmail.isValidEmail else {
            emailError = "Enter a valid email."
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepository.forgotPassword(email: trimmedEmail)
            step = .reset
            secondsLeft = Self.cooldownSeconds
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Addım 2: yeni şifrə

    func resetPassword() async {
        passwordError = nil
        errorMessage = nil

        guard code.count == Self.codeLength else {
            errorMessage = "Enter the 6-digit code."
            return
        }
        guard newPassword.count >= 6 else {
            passwordError = "Password must contain at least 6 characters."
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepository.resetPassword(
                email: trimmedEmail,
                code: code,
                newPassword: newPassword
            )
            didReset = true
        } catch {
            errorMessage = error.localizedDescription
            code = ""
        }
    }

    // MARK: - Yenidən göndər və geri

    func resend() async {
        guard canResend else { return }
        errorMessage = nil
        isLoading = true
        do {
            try await authRepository.forgotPassword(email: trimmedEmail)
            isLoading = false
            secondsLeft = Self.cooldownSeconds
            await runCooldown()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    /// Hər saniyə 1 azaldır, 0-a çatanda dayanır.
    func runCooldown() async {
        while secondsLeft > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            secondsLeft -= 1
        }
    }

    func backToEmail() {
        step = .email
        code = ""
        newPassword = ""
        passwordError = nil
        errorMessage = nil
        secondsLeft = 0
    }
}
