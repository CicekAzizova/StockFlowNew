//
//  SplashView.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import SwiftUI

struct SplashView: View {

    @State private var logoVisible = false
    @State private var textVisible = false
    @State private var showsProgress = false
    var connectionError = false
    var onRetry: () -> Void = {}

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 14) {
                StockFlowLogo(width: 130, isVisible: logoVisible)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.08))
                            .blur(radius: 24)
                    )

                VStack(spacing: 6) {
                    Text(verbatim: AppInfo.name)
                        .font(.inter(.extraBold, size: 36))
                        .foregroundStyle(.white)

                    Text("Stock · Sales · Team")
                        .font(.footnote)
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .opacity(textVisible ? 1 : 0)
                .offset(y: textVisible ? 0 : 10)
            }
            .offset(y: -20)
        }
        .overlay(alignment: .bottom) {
            bottomArea
        }
        .task {
            await runAnimation()
        }
    }

    // MARK: - Fon

    private var background: some View {
        LinearGradient(
            stops: [
                .init(color: .brandDark, location: 0),
                .init(color: .brandTeal, location: 0.6),
                .init(color: .brandGreen, location: 1)
            ],
            startPoint: UnitPoint(x: 0.14, y: -0.18),
            endPoint: UnitPoint(x: 0.86, y: 1.18)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 340, height: 340)
                .offset(x: 110, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 260, height: 260)
                .offset(x: -90, y: 90)
        }
        .clipped()
        .ignoresSafeArea()
    }

    // MARK: - Aşağı hissə (yoxlama və versiya)

    private var bottomArea: some View {
        VStack(spacing: 12) {
            if connectionError {
                errorCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if showsProgress {
                VStack(spacing: 10) {
                    IndeterminateBar()

                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.small)
                        Text("Verifying account...")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .transition(.opacity)
            }

            Text(verbatim: "v\(appVersion)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 32)
        .animation(.easeInOut(duration: 0.3), value: connectionError)
    }
    
    private var errorCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 18))
                    .foregroundStyle(.red)
                    .frame(width: 44, height: 44)
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connection problem")
                        .font(.inter(.bold, size: 15))
                        .foregroundStyle(Color.brandDark)
                    Text("Check your internet connection and try again")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }

                Spacer(minLength: 0)
            }

            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try again")
                }
                .font(.inter(.bold, size: 15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.brandTeal)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 20)
    }

    // MARK: - Animasiya ardıcıllığı

    private func runAnimation() async {
        try? await Task.sleep(for: .milliseconds(150))
        logoVisible = true

        try? await Task.sleep(for: .milliseconds(650))
        withAnimation(.easeOut(duration: 0.5)) {
            textVisible = true
        }

        try? await Task.sleep(for: .milliseconds(1200))
        withAnimation {
            showsProgress = true
        }
    }
}

// MARK: - Sonsuz gedən zolaq

private struct IndeterminateBar: View {

    @State private var moving = false

    var body: some View {
        Capsule()
            .fill(.white.opacity(0.25))
            .frame(width: 90, height: 3)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.white)
                    .frame(width: 34, height: 3)
                    .offset(x: moving ? 56 : 0)
            }
            .clipShape(Capsule())
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    moving = true
                }
            }
    }
}

#Preview {
    SplashView()
}

#Preview {
    SplashView()
}
