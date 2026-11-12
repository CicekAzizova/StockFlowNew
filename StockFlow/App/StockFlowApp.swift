//
//  StockFlowApp.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import SwiftUI

@main
struct StockFlowApp: App {
    let dependencies: AppDependencies
    @State private var isSplashVisible = true
    @State private var appStateManager: AppStateManager
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let dependencies = AppDependencies()
        self.dependencies = dependencies
        
        if CommandLine.arguments.contains("-uitesting") {
            try? dependencies.tokenStorage.deleteToken()
            dependencies.appLockManager.disablePin()
            dependencies.languageManager.language = .english
        }
        
        let appStateManager = AppStateManager(tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository)
        
        appStateManager.onLogout = {
            dependencies.productsStore.reset()
            dependencies.salesStore.reset()
            dependencies.appLockManager.disablePin()
            
        }
        
        _appStateManager = State(initialValue: appStateManager)
    }
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppRouter(dependencies: dependencies, appStateManager: appStateManager)
                
                if  isSplashVisible {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
                
                if appStateManager.state == .authenticated && dependencies.appLockManager.isLocked {
                    LockView()
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .environment(appStateManager)
            .environment(dependencies.appLockManager)
            .environment(dependencies.appPreferences)
            .preferredColorScheme(dependencies.appPreferences.colorSchemeOverride)
            .environment(dependencies.languageManager)
            .environment(\.locale, dependencies.languageManager.locale)
            .environment(dependencies.catalogStore)
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .background:
                    dependencies.appLockManager.appDidEnterBackground()
                case .active:
                    dependencies.appLockManager.appDidBecomeActive()
                default:
                    break
                }
            }
            .task {
                let startedAt = ContinuousClock.now
                await appStateManager.readToken()
                let minimumDuration = Duration.seconds(1.2)
                let elapsed = ContinuousClock.now - startedAt
                if !CommandLine.arguments.contains("-uitesting"), elapsed < minimumDuration {
                    try? await Task.sleep(for: minimumDuration - elapsed)
                }
                
                withAnimation(.easeOut(duration: 0.3)) {
                    isSplashVisible = false
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: .sessionExpired) {
                    appStateManager.logout()
                    appStateManager.onRevokeSession = {
                        refreshToken in
                        Task {
                            await dependencies.authRepository.logout(refreshToken: refreshToken)
                        }
                    }
                }
            }
        }
    }
}
