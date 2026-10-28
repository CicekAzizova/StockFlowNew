//
//  ProductsView.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//
import SwiftUI

struct ProductsView: View {
    @State var viewModel: ProductViewModel
    @Binding var path: NavigationPath
    let canManageProducts: Bool
    
    init(
        viewModel: ProductViewModel,
        path: Binding<NavigationPath>,
        canManageProducts: Bool = false
    ) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.canManageProducts = canManageProducts
    }
    
    private var emptyDescription: LocalizedStringKey {
        canManageProducts
        ? "Add your first product to get started."
        : "No products are available yet."
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            if viewModel.allProducts.isEmpty {
                ContentUnavailableView(
                    "No Products",
                    systemImage: "shippingbox",
                    description: Text(emptyDescription)
                )
            } else {
                productsList
            }
        case .error(let message):
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
    
    private var productsList: some View {
        VStack {
            ProductFilterPicker(selectedFilter: $viewModel.selectedFilter)
            
            if viewModel.filteredProducts.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search or filter.")
                )
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.filteredProducts, id: \.id) { product in
                            NavigationLink(value: ProductRoute.productDetail(product)) {
                                SummaryCardView(product: product)
                            }
                            .task {
                                if product.id == viewModel.filteredProducts.last?.id {
                                    await viewModel.loadMoreProducts()
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                ProductsHeader(
                    count: viewModel.productsCount,
                    onAdd: canManageProducts
                    ? { path.append(ProductRoute.addProduct) }
                    : nil
                )
                
                ProductSearchField(query: $viewModel.query)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .padding()
            .dismissKeyboardOnTap()
            .task {
                await viewModel.loadProductsIfNeeded()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}
#if DEBUG
#Preview("Success") {
    @Previewable @State var path = NavigationPath()
    let store = ProductsStore(productRepository: PreviewProductRepository())
    ProductsView(viewModel: ProductViewModel(productStore: store), path: $path, canManageProducts: true)
}

#Preview("Empty") {
    @Previewable @State var path = NavigationPath()
    let store = ProductsStore(productRepository: PreviewProductRepository(result: .success([])))
    ProductsView(viewModel: ProductViewModel(productStore: store), path: $path, canManageProducts: true)
}

#Preview("Error") {
    @Previewable @State var path = NavigationPath()
    let store = ProductsStore(productRepository: PreviewProductRepository(result: .failure(PreviewError.failed)))
    ProductsView(viewModel: ProductViewModel(productStore: store), path: $path)
}

#Preview("Loading") {
    @Previewable @State var path = NavigationPath()
    let store = ProductsStore(productRepository: PreviewProductRepository(delay: .seconds(3600)))
    ProductsView(viewModel: ProductViewModel(productStore: store), path: $path)
}
#Preview("Dark") {
    @Previewable @State var path = NavigationPath()
    let store = ProductsStore(productRepository: PreviewProductRepository())
    ProductsView(viewModel: ProductViewModel(productStore: store), path: $path, canManageProducts: true)
        .preferredColorScheme(.dark)
}
#endif
