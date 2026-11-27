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
    @Environment(\.scenePhase) private var scenePhase

    @State private var pin = ""
    @State private var isWrong = false
    @State private var isCorrect = false
    @State private var didAutoPrompt = false

    var body: some View {
        ZStack {
            BrandHeaderBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                logo

                profile

                if appLockManager.isLockedOut {
                    lockoutSection
                } else {
                    pinSection
                }

                Spacer(minLength: 0)

                forgotButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .task(id: appLockManager.isLockedOut) {
            while appLockManager.isLockedOut, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                appLockManager.refreshLockout()
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            appLockManager.refreshLockout()
            guard !didAutoPrompt else { return }
            didAutoPrompt = true
            _ = await appLockManager.unlockWithBiometrics()
        }
    }

    // MARK: - Yuxarı hissə

    private var logo: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
            Text(verbatim: AppInfo.name)      .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.9))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var profile: some View {
        VStack(spacing: 10) {
            avatar

            Text("Hello, \(appStateManager.user?.name ?? "")")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(verbatim: subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private var avatar: some View {
        if let url = appStateManager.user?.avatarUrl, !url.isEmpty {
            RemoteImageView(imageUrl: url, width: 72, height: 72, cornerRadius: 22)
        } else {
            Text(verbatim: initials)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color.brandCoral, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var initials: String {
        String(appStateManager.user?.name.prefix(1) ?? "?").uppercased()
    }

    private var subtitle: String {
        let store = appStateManager.user?.storeName ?? ""
        let role = appStateManager.user?.role == .owner
            ? String(localized: "Owner")
            : String(localized: "Sales Associate")
        return store.isEmpty ? role : "\(store) · \(role)"
    }

    // MARK: - PIN

    private var pinSection: some View {
        VStack(spacing: 18) {
            Text("Enter your PIN")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))

            PINDotsView(filledCount: pin.count, tint: dotsColor)

            Text("Wrong PIN · \(appLockManager.attemptsLeft) attempts left")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.brandCoral.opacity(0.28), in: Capsule())
                .overlay(Capsule().stroke(Color.brandCoral.opacity(0.5), lineWidth: 1))
                .opacity(isWrong ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: isWrong)
            PINPadView(onDigit: append, onDelete: deleteLast)

            if appLockManager.isBiometricsEnabled {
                Button {
                    Task { _ = await appLockManager.unlockWithBiometrics() }
                } label: {
                    Label("Face ID", systemImage: "faceid")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
    private var dotsColor: Color {
        if isCorrect { return .brandGreen }
        if isWrong { return .brandCoral }
        return .white
    }

    // MARK: - Blok

    private var lockoutSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.9), lineWidth: 3)
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Image(systemName: "lock.fill")
                        .font(.subheadline)
                    Text(verbatim: timeText)
                        .font(.title2.weight(.bold))
                    Text("wait")
                        .font(.caption2)
                }
                .foregroundStyle(.white)
            }
            .padding(.top, 10)

            Text("Too many wrong attempts")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Entry is paused for security. Wait, or sign in with your password.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))

            if appLockManager.isBiometricsEnabled {
                Button {
                    Task { _ = await appLockManager.unlockWithBiometrics() }
                } label: {
                    Label("Unlock with Face ID", systemImage: "faceid")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.brandDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white, in: Capsule())
                }
                .padding(.top, 6)
            }
        }
    }

    private var timeText: String {
        let seconds = appLockManager.lockoutSecondsLeft
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Aşağı

    private var forgotButton: some View {
        Button {
            appStateManager.logout()
        } label: {
            VStack(spacing: 2) {
                Text("Forgot your PIN?")
                    .foregroundStyle(.white.opacity(0.7))
                Text("Sign in with your password")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .font(.footnote)
        }
    }

    // MARK: - Daxiletmə

    private func append(_ digit: String) {
        guard !appLockManager.isLockedOut, pin.count < 4 else { return }
        isWrong = false
        pin += digit

        guard pin.count == 4 else { return }

        if appLockManager.unlock(with: pin) {
            isCorrect = true
        } else {
            isWrong = true
            pin = ""
        }
    }

    private func deleteLast() {
        if !pin.isEmpty {
            pin.removeLast()
        }
    }
}
