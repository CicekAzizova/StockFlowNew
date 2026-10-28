//
//  OwnerTabView.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//
import SwiftUI

struct OwnerTabView: View {
    let dependencies: AppDependencies
    let appStateManager: AppStateManager

    let user: User?

    @Environment(LanguageManager.self) private var languageManager
    @State private var homePath = NavigationPath()
    @State private var productPath = NavigationPath()
    @State private var teamPath = NavigationPath()
    
    var body: some View {
        TabView {
            
            //MARK: - Home
            
            Tab {
                NavigationStack(path: $homePath) {
                    if let user {
                        HomeView(
                            viewModel: dependencies.makeHomeViewModel(),
                            path: $homePath,
                            user: user
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            HomeDestinationView(
                                route: route,
                                dependencies: dependencies,
                                path: $homePath,
                            )
                        }
                        .navigationDestination(for: ProductRoute.self) { route in
                            ProductDestinationView(
                                route: route,
                                dependencies: dependencies,
                                path: $homePath,
                                canManageProducts: true
                            )
                        }
                        .navigationDestination(for: SalesRoute.self) { route in
                            SalesDestinationView(route: route, dependencies: dependencies)
                        }
                    }
                }
                .id(languageManager.language)
                
            } label: {
                Image(.homeIcon)
                    .renderingMode(.template)
                Text("Home")
            }
            
            //MARK: - Products
            
            Tab {
                NavigationStack(
                    path: $productPath
                ) {
                    ProductsView(
                        viewModel: dependencies.makeProductViewModel(),
                        path: $productPath,
                        canManageProducts: true
                    )
                    .navigationDestination(
                        for: ProductRoute.self
                    ) { route in
                        ProductDestinationView(
                            route: route,
                            dependencies: dependencies,
                            path: $productPath,
                            canManageProducts: true
                        )
                    }
                }
                .id(languageManager.language)
            } label: {
                Image(.productsIcon)
                    .renderingMode(.template)
                Text("Products")
            }
            
            //MARK: - Team
            
            Tab {
                NavigationStack(path: $teamPath) {
                    TeamView(path: $teamPath, viewModel: dependencies.makeTeamViewModel())
                        .navigationDestination(for: TeamRoute.self) { route in
                            TeamDestinationView(route: route, dependencies: dependencies, path: $teamPath)                        }
                        .navigationDestination(for: SalesRoute.self) { route in
                            SalesDestinationView(route: route, dependencies: dependencies)
                        }
                }
                .id(languageManager.language)
            } label: {
                Image(.teamIcon)
                    .renderingMode(.template)
                Text("Team")
            }
            
            //MARK: - Profile
            
            Tab {
                NavigationStack {
                    ProfileView(
                        viewModel: dependencies
                            .makeProfileViewModel(),
                        appStateManager: appStateManager
                    )
                }
                .id(languageManager.language)
            } label: {
                Image(.profileIcon)
                    .renderingMode(.template)
                Text("Profile")
                    
            }
        }
    }

}
#if DEBUG
#Preview("Success") {
    let dependencies = AppDependencies.preview()
    let appStateManager = AppStateManager(
        tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository
    )

    OwnerTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.owner
    )
}

#Preview("Empty") {
    let dependencies = AppDependencies.preview(productResult: .success([]), salesEmpty: true)
    let appStateManager = AppStateManager(
        tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository
    )

    OwnerTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.owner
    )
}

#Preview("Error") {
    let dependencies = AppDependencies.preview(
        productResult: .failure(PreviewError.failed),
        salesFails: true
    )
    let appStateManager = AppStateManager(
        tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository
    )

    OwnerTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.owner
    )
}
#endif
