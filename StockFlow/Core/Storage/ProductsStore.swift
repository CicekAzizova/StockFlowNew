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
    var totalProducts = 0
    
    private var productsPageSize = 10
    private var lowStockPageSize = 10
    
    var products: [ProductsResponse] = []
    var lowStockProducts: [ProductsResponse] = []
    
    
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
    }
    
    func loadProducts(limit: Int = 10) async throws {
        isLoading = true
        productsPageSize = limit
        currentProductPage = 1
        hasMoreProducts = true
        
        defer {
            isLoading = false
        }
        let response = try await productRepository.getProducts(page: currentProductPage, limit: limit)
        
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
        
        let response = try await productRepository.getProducts(page: nextPage, limit: productsPageSize)
        
        currentProductPage = response.page
        products.append(contentsOf: response.items)
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
        lowStockProducts.append(contentsOf: response.items)
        
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
