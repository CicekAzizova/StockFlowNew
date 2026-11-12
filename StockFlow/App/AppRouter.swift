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
    
    var body: some View {
         content
    }
    
    @ViewBuilder
    var content: some View {
        switch appStateManager.state {
        case .loading:
            SplashView()
        case .unauthenticated:
            LoginView(viewModel: dependencies.makeLoginViewModel(appStateManager: appStateManager), dependencies: dependencies, appStateManager: appStateManager)
        case .authenticated:
            authenticatedContent
        }
    }

    /// Ardıcıllıq: (yeni owner) mağaza wizard-ı → PIN → Panel.
    @ViewBuilder
    private var authenticatedContent: some View {
        if appStateManager.user?.role == .owner,
           appStateManager.user?.onboardingCompleted == false {
            OnboardingView(
                viewModel: dependencies.makeOnboardingViewModel(appStateManager: appStateManager)
            )
        } else if !appLockManager.isPinEnabled {
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
