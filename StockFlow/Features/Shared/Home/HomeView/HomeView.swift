//
//  HomeView.swift
//  StockFlow
//
//  Created by Cicek on 02.10.26.
//

import SwiftUI

struct HomeView: View {
    
    @State var viewModel: HomeViewModel
    @Binding var path: NavigationPath
    
    let user: User
    
    init(
        viewModel: HomeViewModel,
        path: Binding<NavigationPath>,
        user: User
    ) {
        self._viewModel = State(initialValue: viewModel)
        self._path = path
        self.user = user
    }
    
    var homeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
               
                HomeSummaryGrid(
                    productsCount: viewModel.productsCount,
                    lowStockCount: viewModel.lowStockCount,
                    associatesCount: viewModel.associatesCount
                )
                
                LowStockSection(products: viewModel.lowStockProducts, path: $path)
            }
            .padding(16)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HomeHeaderView(
                    user: user,
                    todaySales: viewModel.todaySales,
                    todayOrders: viewModel.todayOrders,
                    differenceFromYesterday: viewModel.differenceFromYesterday,
                    weeklySales: viewModel.weeklySales
                )
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadHome()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
            
        case .loaded:
            homeView
            
        case .error(let error):
            ContentUnavailableView {
                Label(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle"
                )
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
#if DEBUG
#Preview("Success") {
    @Previewable @State var path = NavigationPath()
    let viewModel = HomeViewModel(
        productStore: ProductsStore(productRepository: PreviewProductRepository()),
        salesStore: SalesStore(salesRepository: PreviewSalesRepository())
    )
    HomeView(viewModel: viewModel, path: $path, user: PreviewData.owner)
}

#Preview("Error") {
    @Previewable @State var path = NavigationPath()
    let viewModel = HomeViewModel(
        productStore: ProductsStore(productRepository: PreviewProductRepository()),
        salesStore: SalesStore(salesRepository: PreviewSalesRepository(fails: true))
    )
    HomeView(viewModel: viewModel, path: $path, user: PreviewData.owner)
}
#endif
