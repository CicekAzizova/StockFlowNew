//
//  AppRouter.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//


import SwiftUI

struct AppRouter: View {
    
    var dependencies: AppDependencies
    let appStateManager: AppStateManager
    @Environment(AppLockManager.self) private var appLockManager
    @State private var skippedVerification = false
    @AppStorage("has_seen_welcome") private var hasSeenWelcome = false
    @State private var isRegistering = false
    
    var body: some View {
         content
            .onChange(of: appStateManager.state) { _, newState in
                        if newState == .authenticated {
                            hasSeenWelcome = true
                        }
                    }
    }
    
    @ViewBuilder
    var content: some View {
        switch appStateManager.state {
        case .loading:
            SplashView()
        case .unauthenticated:
            if hasSeenWelcome {
                LoginView(
                    viewModel: dependencies.makeLoginViewModel(appStateManager: appStateManager),
                    dependencies: dependencies,
                    appStateManager: appStateManager
                )
            } else {
                NavigationStack {
                    WelcomeView(
                        onRegister: { isRegistering = true },
                        onSignIn: { hasSeenWelcome = true }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(isPresented: $isRegistering) {
                        CreateStoreView(
                            viewModel: dependencies.makeCreateStoreViewModel(appStateManager: appStateManager)
                        )
                    }
                }
            }
        case .authenticated:
            authenticatedContent
        }
    }

    /// Ardıcıllıq: (yeni owner) mağaza wizard-ı → PIN → Panel.
    @ViewBuilder
    private var authenticatedContent: some View {
        if appStateManager.user?.role == .owner,
               appStateManager.user?.emailVerified == false,
               appStateManager.user?.onboardingCompleted == false,
               !skippedVerification {
                EmailVerificationView(
                    viewModel: dependencies.makeEmailVerificationViewModel(appStateManager: appStateManager),
                    onSkip: { skippedVerification = true },
                    onSignOut: { appStateManager.logout() }
                )
            } else if appStateManager.user?.role == .owner,
                      appStateManager.user?.onboardingCompleted == false {
                OnboardingView(
                    viewModel: dependencies.makeOnboardingViewModel(appStateManager: appStateManager),
                    onSignOut: { appStateManager.logout() }
                )
            } else if !appLockManager.isPinEnabled && !appLockManager.hasSkippedPinSetup {
            PINSetupView()
        } else {
            switch appStateManager.user?.role {
            case .owner:
                OwnerTabView(
                    dependencies: dependencies,
                    appStateManager: appStateManager,
                    user: appStateManager.user
                )
            case .seller:
                SellerTabView(
                    dependencies: dependencies,
                    appStateManager: appStateManager,
                    user: appStateManager.user
                )
            case .none:
                ProgressView()
            }
        }
    }
}
