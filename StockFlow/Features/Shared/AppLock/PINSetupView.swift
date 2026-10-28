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
    }

    @State private var step: Step = .enter
    @State private var firstPIN = ""
    @State private var pin = ""
    @State private var errorMessage: LocalizedStringKey?

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

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
    }

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
                firstPIN = ""
                pin = ""
                step = .enter
                return
            }

            do {
                try appLockManager.enablePin(pin)
                // isPinEnabled = true olur, AppRouter özü əsas ekrana keçir.
            } catch {
                errorMessage = "Could not save the PIN. Please try again."
                firstPIN = ""
                pin = ""
                step = .enter
            }
        }
    }

    private func deleteLast() {
        if !pin.isEmpty {
            pin.removeLast()
        }
    }
}
