//
//  PINSetupView.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//

import SwiftUI

struct PINSetupView: View {

    @Environment(AppLockManager.self) private var appLockManager

    private enum Step {
        case enter
        case confirm
        case biometrics
    }

    @State private var step: Step = .enter
    @State private var firstPIN = ""
    @State private var confirmedPIN = ""
    @State private var pin = ""
    @State private var isSaving = false
    @State private var errorMessage: LocalizedStringKey?

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if step == .biometrics {
                    biometricActions
                } else {
                    pinEntry
                }
            }
        }
    }

    // MARK: - Header (üç mərhələ üçün eyni gradient)

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                if step == .confirm {
                    BrandHeaderIconButton(
                        systemImage: "chevron.left",
                        accessibilityLabel: "Back"
                    ) {
                        goBack()
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                if step == .enter {
                    Button("Skip") {
                        appLockManager.skipPinSetup()
                    }
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.white.opacity(0.9))
                }
            }

            Image(systemName: step == .biometrics ? "faceid" : "lock.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 64, height: 64)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .brandHeaderBackground()
    }

    // MARK: - PIN yazma

    private var pinEntry: some View {
        VStack(spacing: 24) {
            Spacer()
            
            PINDotsView(filledCount: pin.count, tint: .brandTeal)
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            } else {
                Text("You'll use this PIN every time you open the app")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            PINPadView(onDigit: append, onDelete: deleteLast, onDark: false)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Face ID təklifi

    private var biometricActions: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                benefitRow(
                    icon: "bolt.fill",
                    title: "Faster sign in",
                    text: "Open the app with a glance"
                )
                benefitRow(
                    icon: "lock.shield.fill",
                    title: "Still secure",
                    text: "Your face data never leaves your iPhone"
                )
                benefitRow(
                    icon: "key.fill",
                    title: "PIN as backup",
                    text: "You can always use your PIN instead"
                )
            }
            .padding(.top, 28)

            Spacer()

            AppButtonView(
                title: "Enable Face ID",
                isLoading: isSaving,
                usesBrandGradient: true
            ) {
                Task { await enableFaceID() }
            }

            Button("Not now") {
                savePIN(confirmedPIN, useBiometrics: false)
            }
            .font(.inter(.bold, size: 15))
            .foregroundStyle(.textSecondary)
            .padding(.vertical, 8)
            .disabled(isSaving)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private func benefitRow(icon: String, title: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 40, height: 40)
                .background(Color.brandTeal.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.textPrimary)
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    // MARK: - Mətnlər

    private var title: LocalizedStringKey {
        switch step {
        case .enter: "Create a PIN"
        case .confirm: "Confirm your PIN"
        case .biometrics: "Use Face ID?"
        }
    }

    private var subtitle: LocalizedStringKey {
        switch step {
        case .enter: "Choose a 4-digit PIN to protect the app"
        case .confirm: "Enter the same PIN again"
        case .biometrics: "Unlock the app with your face instead of typing your PIN."
        }
    }

    // MARK: - Məntiq

    private func append(_ digit: String) {
        guard pin.count < 4 else { return }
        pin += digit

        guard pin.count == 4 else { return }

        switch step {
        case .enter:
            firstPIN = pin
            pin = ""
            errorMessage = nil
            step = .confirm

        case .confirm:
            guard pin == firstPIN else {
                errorMessage = "PINs do not match. Try again."
                resetToStart()
                return
            }

            if appLockManager.canUseBiometrics {
                confirmedPIN = pin
                pin = ""
                errorMessage = nil
                step = .biometrics
            } else {
                savePIN(pin, useBiometrics: false)
            }

        case .biometrics:
            break
        }
    }

    private func deleteLast() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }

    private func goBack() {
        errorMessage = nil
        resetToStart()
    }

    private func enableFaceID() async {
        isSaving = true
        defer { isSaving = false }
        if await appLockManager.verifyBiometrics() {
            savePIN(confirmedPIN, useBiometrics: true)
        }
    }

    private func savePIN(_ value: String, useBiometrics: Bool) {
        do {
            try appLockManager.enablePin(value)
            if useBiometrics {
                appLockManager.setBiometrics(true)
            }
        } catch {
            errorMessage = "Could not save the PIN. Please try again."
            resetToStart()
        }
    }

    private func resetToStart() {
        firstPIN = ""
        confirmedPIN = ""
        pin = ""
        step = .enter
    }
}
