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
        }
        
        let appStateManager = AppStateManager(tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository)
        
        appStateManager.onLogout = {
            try? dependencies.appLockManager.enablePin("1234")
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
            .onChange(of: scenePhase) { _, phase in
                if phase == .background {
                    dependencies.appLockManager.lockIfNeeded()
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
                }
            }
        }
    }
}
