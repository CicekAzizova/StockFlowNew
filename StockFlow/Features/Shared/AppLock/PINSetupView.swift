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
    @State private var errorMessage: LocalizedStringKey?

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            if step == .biometrics {
                biometricOffer
            } else {
                pinEntry
            }
        }
    }

    // MARK: - PIN yazma

    private var pinEntry: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.primaryBlue)

            VStack(spacing: 8) {
                Text(step == .enter ? LocalizedStringKey("Create a PIN") : LocalizedStringKey("Confirm your PIN"))
                    .font(.title2.bold())
                    .foregroundStyle(Color.primaryBlue)

                Text(errorMessage ?? subtitle)
                    .font(.footnote)
                    .foregroundStyle(errorMessage == nil ? Color.secondary : Color.red)
                    .multilineTextAlignment(.center)
            }

            PINDotsView(filledCount: pin.count)

            PINPadView(onDigit: append, onDelete: deleteLast)

            Spacer()
        }
        .padding(24)
    }

    // MARK: - Face ID təklifi

    private var biometricOffer: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "faceid")
                .font(.system(size: 56))
                .foregroundStyle(Color.primaryBlue)

            VStack(spacing: 8) {
                Text("Use Face ID?")
                    .font(.title2.bold())
                    .foregroundStyle(Color.primaryBlue)

                Text("Unlock the app with your face instead of typing your PIN.")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task { await enableFaceID() }
                } label: {
                    Text("Enable Face ID")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button("Not now") {
                    savePIN(confirmedPIN, useBiometrics: false)
                }
                .foregroundStyle(Color.primaryBlue)
            }
        }
        .padding(24)
    }

    // MARK: - Məntiq

    private var subtitle: LocalizedStringKey {
        step == .enter
            ? "Choose a 4-digit PIN to protect the app"
            : "Enter the same PIN again"
    }

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
        if !pin.isEmpty {
            pin.removeLast()
        }
    }

    private func enableFaceID() async {
        if await appLockManager.verifyBiometrics() {
            savePIN(confirmedPIN, useBiometrics: true)
        }
        // Face ID alınmasa, ekranda qalır: yenidən cəhd edə və ya "Not now" seçə bilər.
    }

    private func savePIN(_ value: String, useBiometrics: Bool) {
        do {
            try appLockManager.enablePin(value)
            if useBiometrics {
                appLockManager.setBiometrics(true)
            }
            // isPinEnabled = true olur, AppRouter özü əsas ekrana keçir.
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
