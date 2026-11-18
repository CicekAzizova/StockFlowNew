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
    @Environment(CatalogStore.self) private var catalogStore
    @State private var isScannerPresented = false
    @State private var notFoundSku: String?
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
            if viewModel.allProducts.isEmpty && !viewModel.hasActiveFilter {
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
        VStack(spacing: 0) {
            if viewModel.filteredProducts.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search or filter.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10){
                        ForEach(viewModel.filteredProducts, id: \.id) { product in
                            NavigationLink(value: ProductRoute.productDetail(product)) {
                                ProductRowView(product: product)
                            }
                            .task {
                                if product.id == viewModel.filteredProducts.last?.id {
                                    await viewModel.loadMoreProducts()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80)
                    .padding(.top, 4)
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ProductsHeader(
                    locationSwitcher: viewModel.locationSwitcher,
                    query: $viewModel.query,
                    filter: $viewModel.selectedFilter,
                    stats: viewModel.stats,
                    onScan: {
                        isScannerPresented = true

                    }
                )

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
            }
            .dismissKeyboardOnTap()
            .task {
                await viewModel.loadProductsIfNeeded()
            }
            .task(id: viewModel.searchKey) {
                await viewModel.applyFilters()
            }
            .task {
                if canManageProducts { await viewModel.locationSwitcher?.load() }
            }
            .task { await catalogStore.loadIfNeeded() }
            .onReceive(NotificationCenter.default.publisher(for: .locationsChanged)) { _ in
                Task { if canManageProducts { await viewModel.locationSwitcher?.load() } }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: .activeLocationChanged)) { _ in
                Task { await viewModel.refresh() }
            }

            if canManageProducts {
                addButton
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $isScannerPresented) {
            scannerSheet
        }
        .alert(
            "Product not found",
            isPresented: Binding(
                get: { notFoundSku != nil },
                set: { if !$0 { notFoundSku = nil } }
            )
        ) {
            if canManageProducts {
                Button("Add product") { path.append(ProductRoute.addProduct) }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(verbatim: notFoundSku ?? "")
        }
    }
    
    private var scannerSheet: some View {
        ZStack(alignment: .topTrailing) {
            BarcodeInputView(placeholder: "Enter SKU manually") { code in
                isScannerPresented = false
                Task { await handleScan(code) }
            }

            Button {
                isScannerPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.4))
            }
            .padding()
        }
    }

    private func handleScan(_ code: String) async {
        if let product = await viewModel.findProduct(sku: code) {
            path.append(ProductRoute.productDetail(product))
        } else {
            notFoundSku = code
        }
    }

    private var addButton: some View {
        Button {
            path.append(ProductRoute.addProduct)
        } label: {
            Label("Add product", systemImage: "plus")
                .font(.inter(.bold, size: 15))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.brandDark, .brandTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        }
        .padding(16)
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
