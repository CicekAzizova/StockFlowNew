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
        VStack(alignment: .leading,spacing: 16) {
            HomeHeaderView(
                user: user,
                subtitle: user.role == .owner
                ? LocalizedStringKey("Owner access • Full store management")
                : LocalizedStringKey("Sales Associate access • Sales operations")
            )
            ScrollView(showsIndicators: false) {
                HomeSummaryGrid(
                    todaySales: viewModel.todaySales,
                    totalSales: viewModel.revenue,
                    productsCount: viewModel.productsCount,
                    lowStockCount: viewModel.lowStockCount
                )
                .padding(.vertical,16)
                RecentSalesSection(sales: viewModel.recentSales, onSeeAll: {
                    path.append(HomeRoute.salesHistory)
                }, path: $path)
                LowStockSection(products: viewModel.lowStockProducts, path: $path)
            }
        }
        .padding()
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            content
        }
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
