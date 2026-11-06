//
//  LowStockViewModel.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import Foundation

@Observable
@MainActor

final class LowStockViewModel {
    
    private let productStore: ProductsStore

    var state: LowStockViewState = .idle
    
    var loadMoreError: String?
    
    var selectedFilter: LowStockFilter = .all
    
    var filteredProducts: [ProductsResponse] {
        products.filter { selectedFilter.matches($0) }
    }
    
    var products: [ProductsResponse] {
        productStore.lowStockProducts
    }
    
    /// Restock pəncərəsi açılan məhsul. nil olsa pəncərə bağlıdır.
    var restockTarget: ProductsResponse?
    var isRestocking = false
    var restockError: String?

    init(productStore: ProductsStore) {
        self.productStore = productStore
    }
    
    func count(for filter: LowStockFilter) -> Int {
        products.filter { filter.matches($0) }.count
    }
    
    func loadProductsIfNeeded() async {
        guard !state.isLoaded else { return }
        await loadProducts()
    }
    
    func loadProducts() async {
        let previousState = state
        if !state.isLoaded { state = .loading }

        do {
            try await productStore.loadLowStock(limit: 100)
            state = .loaded
        } catch is CancellationError {
            state = previousState
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func refresh() async {
        await loadProducts()
    }

    func loadMoreProducts() async {
        loadMoreError = nil
        do {
            try await productStore.loadMoreLowStock()
        }
        catch is CancellationError {
            return
        }
        catch {
            loadMoreError = error.localizedDescription
        }
    }
    func startRestock(_ product: ProductsResponse) {
        restockError = nil
        restockTarget = product
    }
    
    /// Seçilmiş məhsulun qalığına ədəd əlavə edir.
    func restock(quantity: Int) async {
        guard let target = restockTarget, !isRestocking else { return }

        isRestocking = true
        restockError = nil
        defer { isRestocking = false }

        do {
            _ = try await productStore.restockProduct(id: target.id, quantity: quantity)
            restockTarget = nil
        } catch is CancellationError {
            return
        } catch {
            restockError = error.localizedDescription
        }
    }
}
