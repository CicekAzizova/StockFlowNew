//
//  LockView.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//

import SwiftUI

struct LockView: View {

    @Environment(AppLockManager.self) private var appLockManager
    @Environment(AppStateManager.self) private var appStateManager

    @State private var pin = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.primaryBlue)

                VStack(spacing: 8) {
                    Text("Welcome back, \(appStateManager.user?.name ?? "")")
                        .font(.title2.bold())
                        .foregroundStyle(Color.primaryBlue)

                    Text(errorMessage ?? "Enter your PIN")
                        .font(.footnote)
                        .foregroundStyle(errorMessage == nil ? Color.secondary : Color.red)
                }

                PINDotsView(filledCount: pin.count)

                PINPadView(onDigit: append, onDelete: deleteLast)

                Button("Forgot PIN? Log out") {
                    appStateManager.logout()
                }
                .font(.footnote)
                .foregroundStyle(Color.primaryBlue)

                Spacer()
            }
            .padding(24)
        }
    }

    private func append(_ digit: String) {
        guard pin.count < 4 else { return }
        pin += digit

        guard pin.count == 4 else { return }

        if !appLockManager.unlock(with: pin) {
            pin = ""
            errorMessage = "Wrong PIN. Try again."
        }
    }

    private func deleteLast() {
        if !pin.isEmpty {
            pin.removeLast()
        }
    }
}
