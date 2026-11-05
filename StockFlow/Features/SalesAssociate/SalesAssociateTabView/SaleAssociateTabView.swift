//
//  Sale.swift
//  StockFlow
//
//  Created by Cicek on 06.10.26.
//

import SwiftUI

struct SaleAssociateTabView: View {
    
    let dependencies: AppDependencies
    let appStateManager: AppStateManager
    @Environment(LanguageManager.self) private var languageManager
    @State private var homePath = NavigationPath()
    @State private var productPath = NavigationPath()
    @State private var salesPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    
    let user: User?
    
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
                                path: $homePath
                            )
                        }
                        .navigationDestination(for: ProductRoute.self) { route in
                            ProductDestinationView(
                                route: route,
                                dependencies: dependencies,
                                path: $homePath
                            )
                        }
                        .navigationDestination(for: SalesRoute.self) { route in
                            SalesDestinationView(route: route, dependencies: dependencies)
                        }
                        
                        
                    }
                }
                .id(languageManager.language)
            }label: {
                Image(.homeIcon)
                    .renderingMode(.template)
                Text("Home")            }
            
            //MARK: - Products
            
            Tab {
                NavigationStack(path: $productPath) {
                    ProductsView(
                        viewModel: dependencies.makeProductViewModel(),
                        path: $productPath
                    )
                    .navigationDestination(for: ProductRoute.self) { route in
                        ProductDestinationView(
                            route: route,
                            dependencies: dependencies,
                            path: $productPath
                        )
                    }
                }
                .id(languageManager.language)
            }label: {
                Image(.productsIcon)
                    .renderingMode(.template)
                Text("Products")            }
            
            //MARK: - Sales
            Tab {
                NavigationStack(path: $salesPath) {
                    SalesAssociateSalesView(viewModel: dependencies.makeSalesAssociateSalesViewModel(), path: $salesPath)
                    
                        .navigationDestination(for: SalesRoute.self) { route in
                            SalesDestinationView(route: route, dependencies: dependencies)
                        }
                }
                .id(languageManager.language)
                
            }label: {
                Image(.salesIcon)
                    .renderingMode(.template)
                Text("Sales")
                
            }
            
            //MARK: - Profile
            
            Tab {
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
                        )
                    }
                }
                .id(languageManager.language)
            }label: {
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

    SaleAssociateTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.salesAssociate
    )
}

#Preview("Empty") {
    let dependencies = AppDependencies.preview(productResult: .success([]), salesEmpty: true)
    let appStateManager = AppStateManager(
        tokenStorage: dependencies.tokenStorage, userRepository: dependencies.userRepository
    )

    SaleAssociateTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.salesAssociate
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

    SaleAssociateTabView(
        dependencies: dependencies,
        appStateManager: appStateManager,
        user: PreviewData.salesAssociate
    )
}
#endif
