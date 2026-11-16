//
//  EmailVerificationViewModel.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmailVerificationViewModel {

    static let codeLength = 6
    private static let cooldownSeconds = 60

    var code = ""
    var isVerifying = false
    var isResending = false
    var secondsLeft = EmailVerificationViewModel.cooldownSeconds
    var errorMessage: String?

    var email: String {
        appStateManager.user?.email ?? ""
    }

    var canResend: Bool {
        secondsLeft == 0 && !isResending && !isVerifying
    }

    private let authRepository: AuthRepository
    private let appStateManager: AppStateManager

    init(authRepository: AuthRepository, appStateManager: AppStateManager) {
        self.authRepository = authRepository
        self.appStateManager = appStateManager
    }

    /// 6 rəqəm yığılanda çağırılır.
    func verify() async {
        guard code.count == Self.codeLength, !isVerifying else { return }
        errorMessage = nil
        isVerifying = true
        defer { isVerifying = false }
        do {
            try await authRepository.verifyEmail(code: code)
            // İstifadəçini təsdiqlənmiş kimi işarələyirik, AppRouter özü növbəti ekrana keçir.
            if var user = appStateManager.user {
                user.emailVerified = true
                appStateManager.user = user
            }
        } catch {
            errorMessage = error.localizedDescription
            code = ""
        }
    }

    /// Yeni kod göndərir və geri sayımı yenidən başladır.
    func resend() async {
        guard canResend else { return }
        errorMessage = nil
        isResending = true
        do {
            try await authRepository.resendVerification()
            isResending = false
            secondsLeft = Self.cooldownSeconds
            await runCooldown()
        } catch {
            isResending = false
            errorMessage = error.localizedDescription
        }
    }

    /// Hər saniyə 1 azaldır, 0-a çatanda dayanır. Ekran açılanda da çağırılır.
    func runCooldown() async {
        while secondsLeft > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            secondsLeft -= 1
        }
    }
}
