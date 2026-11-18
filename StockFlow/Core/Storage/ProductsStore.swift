//
//  ProductsStore.swift
//  StockFlow
//
//  Created by Cicek on 30.09.26.
//
import Foundation
import Observation

@Observable
@MainActor
final class ProductsStore {
    
    private let productRepository: ProductRepository
    
    var isLoading: Bool = false
    
    // MARK: - Products Pagination
    private var currentProductPage = 1
    private var hasMoreProducts = true
    private var isLoadingMoreProducts = false
    private var currentQuery: String?
    private var currentStock: String?
    var totalProducts = 0
    
    private var productsPageSize = 10
    private var lowStockPageSize = 10
    
    var products: [ProductsResponse] = []
    var lowStockProducts: [ProductsResponse] = []
    
    var stats: ProductStats?
    
    // MARK: - Low Stock Pagination
    
    private var currentLowStockPage = 1
    private var hasMoreLowStock = true
    private var isLoadingMoreLowStock = false
    var totalLowProducts = 0
    
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    // MARK: - Products
    
    func reset() {
        products = []
        lowStockProducts = []
        totalProducts = 0
        totalLowProducts = 0
        currentProductPage = 1
        currentLowStockPage = 1
        hasMoreProducts = true
        hasMoreLowStock = true
        stats = nil
        currentQuery = nil
        currentStock = nil
    }
    
    /// Çiplərdəki rəqəmlər üçün. Xəta olsa səssiz keçir, siyahı işləməyə davam edir.
    func loadStats() async {
        stats = try? await productRepository.getProductStats()
    }
    
    func loadProducts(limit: Int = 10, query: String? = nil, stock: String? = nil) async throws {
        isLoading = true
        productsPageSize = limit
        currentProductPage = 1
        hasMoreProducts = true
        currentQuery = query
        currentStock = stock

        defer {
            isLoading = false
        }
        let response = try await productRepository.getProducts(
            page: currentProductPage,
            limit: limit,
            query: query,
            stock: stock
        )

        products = response.items
        totalProducts = response.total
        hasMoreProducts = response.hasNext
    }
    
    func loadMoreProducts() async throws {
        guard hasMoreProducts else { return }
        guard !isLoadingMoreProducts else { return }
        
        isLoadingMoreProducts = true
        
        defer {
            isLoadingMoreProducts = false
        }
        
        let nextPage = currentProductPage + 1
        
        let response = try await productRepository.getProducts(
            page: nextPage,
            limit: productsPageSize,
            query: currentQuery,
            stock: currentStock
        )
        
        currentProductPage = response.page
        let existingProductIds = Set(products.map(\.id))
        products.append(contentsOf: response.items.filter { !existingProductIds.contains($0.id) })
        totalProducts = response.total
        hasMoreProducts = response.hasNext
    }
    
    // MARK: - Low Stock
    
    func loadLowStock(limit: Int = 10) async throws {
        lowStockPageSize = limit
        currentLowStockPage = 1
        hasMoreLowStock = true
        
        let response = try await productRepository.getLowStockProducts(page: currentLowStockPage, limit: limit)
        
        lowStockProducts = response.items
        totalLowProducts = response.total
        hasMoreLowStock = response.hasNext
    }
    
    func loadMoreLowStock() async throws {
        guard hasMoreLowStock else { return }
        guard !isLoadingMoreLowStock else { return }
        
        isLoadingMoreLowStock = true
        
        defer {
            isLoadingMoreLowStock = false
        }
        
        let nextPage = currentLowStockPage + 1
        
        let response = try await productRepository.getLowStockProducts(
            page: nextPage,
            limit: lowStockPageSize
        )
        // Eyni məhsulu ikinci dəfə əlavə etmə (səhifələr üst-üstə düşə bilər).
        let existingIds = Set(lowStockProducts.map(\.id))
        lowStockProducts.append(contentsOf: response.items.filter { !existingIds.contains($0.id) })
        
        currentLowStockPage = response.page
        totalLowProducts = response.total
        hasMoreLowStock = response.hasNext
    }
    
    func addProduct(_ request: ProductRequest) async throws -> ProductsResponse {
        let response = try await productRepository.createProduct(request)
        try await loadProducts(limit: productsPageSize)
        await refreshLowStock()
        return response
    }
    
    func saveProduct(id: Int, request: ProductRequest) async throws -> ProductsResponse {
        let response = try await productRepository.updateProduct(id: id, request: request)
        
        if let index = products.firstIndex(where: { $0.id == id }) {
            products[index] = response
        }
        if let index = lowStockProducts.firstIndex(where: { $0.id == id }) {
            lowStockProducts[index] = response
        }
        
        await refreshLowStock()
        return response
    }
    
    
    
    enum ProductLookup {
        case found(ProductsResponse)
        case notFound
        case failed
    }

    /// Barkodla məhsulu axtarır. Siyahılara toxunmur.
    func lookupProduct(sku: String) async -> ProductLookup {
        do {
            return .found(try await productRepository.getProduct(bySku: sku))
        } catch NetworkError.serverError(let statusCode, _) where statusCode == 404 {
            return .notFound
        } catch {
            return .failed
        }
    }
    
    /// Bir məhsulu serverdən təzələyir və siyahılardakı köhnə nüsxəni əvəz edir.
    func refreshProduct(sku: String) async -> ProductsResponse? {
        guard let fresh = try? await productRepository.getProduct(bySku: sku) else { return nil }

        if let index = products.firstIndex(where: { $0.id == fresh.id }) {
            products[index] = fresh
        }
        if let index = lowStockProducts.firstIndex(where: { $0.id == fresh.id }) {
            lowStockProducts[index] = fresh
        }
        await refreshLowStock()
        return fresh
    }
    
    
    func restockProduct(id: Int, quantity: Int) async throws -> ProductsResponse {
        let response = try await productRepository.restockProduct(id: id, quantity: quantity)

        if let index = products.firstIndex(where: { $0.id == id }) {
            products[index] = response
        }
        if let index = lowStockProducts.firstIndex(where: { $0.id == id }) {
            lowStockProducts[index] = response
        }

        await refreshLowStock()
        return response
    }
    
    func deleteProduct(id: Int) async throws {
        try await productRepository.deleteProduct(id: id)
        
        products.removeAll { $0.id == id }
        lowStockProducts.removeAll { $0.id == id }
        totalProducts = max(0, totalProducts - 1)
        
        await refreshLowStock()
    }
    
    // MARK: - Sync
    
    func refreshStock() async {
        try? await loadProducts(limit: productsPageSize)
        await refreshLowStock()
    }
    
    func product(withID id: Int) -> ProductsResponse? {
        products.first { $0.id == id } ?? lowStockProducts.first { $0.id == id }
    }
    
    private func refreshLowStock() async {
        try? await loadLowStock(limit: lowStockPageSize)
    }
    
    // MARK: - Computed Properties
    
    var productsCount: Int {
        totalProducts
    }
    
    var lowStockCount: Int {
        totalLowProducts
    }
    
}
