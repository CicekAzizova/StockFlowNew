//
//  ProductViewModel.swift
//  StockFlow
//
//  Created by Cicek on 28.09.26.
//
import Foundation

@Observable
@MainActor
final class ProductViewModel {
    
    private let productStore: ProductsStore
    let locationSwitcher: LocationSwitcher?
    private let defaults: UserDefaults
    
    private static let filterKey = "products.selectedFilter"
    
    var filter = ProductFilter()
    
    var state: ProductsViewState = .idle
    
    var query: String = ""
    
    var loadMoreError: String?
    private var appliedKey = ""
    
    var selectedFilter: ProductStockFilter {
        didSet { defaults.set(selectedFilter.rawValue, forKey: Self.filterKey) }
    }
    
    var stats: ProductStats? {
        productStore.stats
    }
    
    init(
        productStore: ProductsStore,
        locationSwitcher: LocationSwitcher? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.productStore = productStore
        self.locationSwitcher = locationSwitcher
        self.defaults = defaults
        self.selectedFilter = defaults.string(forKey: Self.filterKey)
            .flatMap(ProductStockFilter.init(rawValue:)) ?? .all
    }
    
    var allProducts: [ProductsResponse] {
        productStore.products
    }
    var productsCount: Int {
        productStore.productsCount
    }
    
    /// Filtr/axtarış artıq serverdə edilir, siyahı olduğu kimi gəlir.
    var filteredProducts: [ProductsResponse] {
        allProducts
    }

    var hasActiveFilter: Bool {
        !query.isEmpty || selectedFilter != .all
    }

    /// Axtarış və ya çip dəyişibmi bilmək üçün.
    var searchKey: String {
        "\(query)|\(selectedFilter.rawValue)|\(filter.subcategory ?? "")|\(filter.forSale.map(String.init) ?? "")|\(filter.sort.rawValue)"
    }
    
    func loadProducts() async {
        let previousState = state

        if !state.isLoaded {
            state = .loading
        }
        appliedKey = searchKey
        do {
            await productStore.loadStats()
            try await productStore.loadProducts(
                limit: 10,
                query: query.trimmingCharacters(in: .whitespaces),
                stock: selectedFilter.apiValue,
                filter: filter
            )
            state = .loaded(allProducts)
        }
        catch is CancellationError {
            state = previousState
        }
        
        catch NetworkError.unknown(let inner) where (inner as? URLError)?.code == .cancelled {
            state = previousState
        }
        
        catch let error as URLError where error.code == .cancelled {
            state = previousState
        }
        catch {
            state = .error(error.localizedDescription)
        }
    }
    
    /// Axtarış yazılanda hər hərfdə sorğu getməsin deyə 0.35 san gözləyir.
    func applyFilters() async {
        guard searchKey != appliedKey else { return }
        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }
        await loadProducts()
    }
    
    func refresh() async {
        await loadProducts()
    }
    
    func loadMoreProducts() async {
        loadMoreError = nil
        do {
            try await productStore.loadMoreProducts()
            state = .loaded(allProducts)
        }catch is CancellationError {
            return
        }
        catch {
            loadMoreError = error.localizedDescription
        }
    }
    
    func loadProductsIfNeeded() async {
        guard case .idle = state else { return }
        await loadProducts()
    }
    /// Barkodla (SKU) məhsulu tapır. Tapılmasa nil.
    func findProduct(sku: String) async -> ProductsResponse? {
        await productStore.refreshProduct(sku: sku)
    }
}
