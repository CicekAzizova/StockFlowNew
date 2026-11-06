//
//  SalesRepository.swift
//  StockFlow
//
//  Created by Cicek on 07.10.26.
//

import Foundation

protocol SalesRepository {
    func getSalesSummary() async throws -> SalesSummaryResponse
    func getRecentSales(
            page: Int,
            limit: Int
        ) async throws -> PaginationResponse<SaleResponse>
    func createSale(_ request: CreateSaleRequest) async throws -> CreateSaleResponse
    func getSales(sellerId: Int, page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse>
    func getDailySales(days: Int) async throws -> DailySalesResponse

}

final class DefaultSalesRepository: SalesRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    func getSalesSummary() async throws -> SalesSummaryResponse{
        return try await networkService.request(SalesEndpoint.summary)
    }
    
    func getRecentSales(page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse> {
        try await networkService.request(SalesEndpoint.recentSales(page: page, limit: limit))
    }
    func createSale(_ request: CreateSaleRequest) async throws -> CreateSaleResponse {
        try await networkService.request(SalesEndpoint.createSale(request))
    }
    func getSales(sellerId: Int, page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse> {
        try await networkService.request(
            SalesEndpoint.sellerSales(sellerId: sellerId, page: page, limit: limit)
        )
    }
    
    func getDailySales(days: Int) async throws -> DailySalesResponse {
        try await networkService.request(SalesEndpoint.daily(days: days))
    }
}
