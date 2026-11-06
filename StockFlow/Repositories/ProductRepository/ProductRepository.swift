//
//  ProductsRepository.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//
import Foundation

protocol ProductRepository {
    func createProduct(_ request: ProductRequest) async throws -> ProductsResponse
    func getProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse>
    func getProduct(bySku sku: String) async throws -> ProductsResponse
    func updateProduct(id: Int, request: ProductRequest) async throws -> ProductsResponse
    func deleteProduct(id: Int) async throws
    func getLowStockProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse>
    func restockProduct(id: Int, quantity: Int) async throws -> ProductsResponse
}

final class DefaultProductRepository: ProductRepository {
  
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func createProduct(_ request: ProductRequest) async throws -> ProductsResponse {
        try await networkService.request(ProductsEndpoint.createProduct(request))
    }
    
    func getProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse> {
        try await networkService.request(ProductsEndpoint.getProducts(page: page, limit: limit))
    }
    
    func getProduct(bySku sku: String) async throws -> ProductsResponse {
        try await networkService.request(ProductsEndpoint.productBySku(sku))
    }
    
    func updateProduct(id: Int, request: ProductRequest) async throws -> ProductsResponse {
        try await networkService.request(ProductsEndpoint.editProduct(id: id, request: request))
    }
    
    func deleteProduct(id: Int) async throws  {
        try await networkService.requestVoid(ProductsEndpoint.deleteProduct(id: id))
    }
    
    func getLowStockProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse> {
        try await networkService.request(ProductsEndpoint.getLowStockProducts(page: page, limit: limit))
    }
    func restockProduct(id: Int, quantity: Int) async throws -> ProductsResponse {
        try await networkService.request(
            ProductsEndpoint.restockProduct(id: id, request: RestockRequest(quantity: quantity))
        )
    }
}
