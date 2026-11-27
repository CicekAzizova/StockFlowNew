//
//  OwnerTabView.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//
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
    @State private var selection: MainTab = .home
    @State private var homePath = NavigationPath()
    @State private var productPath = NavigationPath()
    @State private var salesPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selection) {
            
            //MARK: - Home
            
            Tab(value: MainTab.home) {
                NavigationStack(path: $homePath) {
                    if let user {
                        HomeView(
                            viewModel: dependencies.makeHomeViewModel(includesTeam: true),
                            path: $homePath,
                            user: user
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            HomeDestinationView(
                                route: route,
                                dependencies: dependencies,
                                path: $homePath,
                                canRestock: true
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
                            SalesDestinationView(route: route, dependencies: dependencies, canReturn: true)
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
            
            Tab(value: MainTab.products) {
                NavigationStack(
                    path: $productPath
                ) {
                    ProductsView(
                        viewModel: dependencies.makeProductViewModel(),
                        path: $productPath,
                        canManageProducts: true,
                        mainCategories: user?.mainCategories ?? []
                        
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
            
            //MARK: - Scan (placeholder)
            
            Tab(value: MainTab.scan) {
                Color.clear
            } label: {
                Image(uiImage: UIImage())
                Text(verbatim: " ")
            }
            
            //MARK: - Sales

            Tab(value: MainTab.sales) {
                NavigationStack(path: $salesPath) {
                    SalesView(
                        viewModel: dependencies.makeSalesViewModel(currentUser: user),
                        path: $salesPath, dependencies: dependencies,
                        canFilterBySeller: true
                    )
                        .navigationDestination(for: SalesRoute.self) { route in
                            SalesDestinationView(route: route, dependencies: dependencies, canReturn: true)
                        }
                }
                .id(languageManager.language)
            } label: {
                Image(.salesIcon)
                    .renderingMode(.template)
                Text("Sales")
            }
            
            //MARK: - Profile
            
            Tab(value: MainTab.profile) {
                NavigationStack(path: $profilePath) {
                    ProfileView(
                        viewModel: dependencies.makeProfileViewModel(appStateManager: appStateManager),
                        appStateManager: appStateManager,
                        path: $profilePath
                    )
                    .navigationDestination(for: ProfileRoute.self) { route in
                        ProfileDestinationView(
                            route: route,
                            user: user,
                            dependencies: dependencies,
                            path: $profilePath,
                            canManageTeam: true
                        )
                    }
                    .navigationDestination(for: TeamRoute.self) { route in
                        TeamDestinationView(route: route, dependencies: dependencies, path: $profilePath)
                    }
                    .navigationDestination(for: SalesRoute.self) { route in
                        SalesDestinationView(route: route, dependencies: dependencies, canReturn: true)
                    }
                    
                }
                .id(languageManager.language)
            } label: {
                Image(.profileIcon)
                    .renderingMode(.template)
                Text("Profile")
                    
            }
        }
        .tint(.brandTeal)
        .scanTab(selection: $selection, dependencies: dependencies)
        .onChange(of: languageManager.language) {
            homePath = NavigationPath()
            productPath = NavigationPath()
            salesPath = NavigationPath()
            profilePath = NavigationPath()
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
