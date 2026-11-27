//
//  SalesRepository.swift
//  StockFlow
//
//  Created by Cicek on 07.10.26.
//

import Foundation

protocol SalesRepository {
    func getSalesSummary() async throws -> SalesSummaryResponse
    func createCartSale(_ request: CreateCartSaleRequest) async throws -> CreateSaleResponse
    func getSales(sellerId: Int, page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse>
    func getDailySales(days: Int) async throws -> DailySalesResponse
    func getSalesInRange(
        from: String,
        to: String,
        filter: SalesFilter,
        page: Int,
        limit: Int
    ) async throws -> PaginationResponse<SaleResponse>

    func getSalesTotals(from: String, to: String, filter: SalesFilter) async throws -> SalesTotalsResponse
    
    func createReturn(saleId: Int, request: CreateReturnRequest) async throws -> SaleReturnResponse
    
    func getSale(id: Int) async throws -> SaleResponse
}

final class DefaultSalesRepository: SalesRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    func getSalesSummary() async throws -> SalesSummaryResponse{
        return try await networkService.request(SalesEndpoint.summary)
    }
    
    func createCartSale(_ request: CreateCartSaleRequest) async throws -> CreateSaleResponse {
        try await networkService.request(SalesEndpoint.createCartSale(request))
    }
    
    func getSales(sellerId: Int, page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse> {
        try await networkService.request(
            SalesEndpoint.sellerSales(sellerId: sellerId, page: page, limit: limit)
        )
    }
    
    func getDailySales(days: Int) async throws -> DailySalesResponse {
        try await networkService.request(SalesEndpoint.daily(days: days))
    }
    
    func getSalesInRange(
        from: String,
        to: String,
        filter: SalesFilter,
        page: Int,
        limit: Int
    ) async throws -> PaginationResponse<SaleResponse> {
        try await networkService.request(
            SalesEndpoint.rangeSales(from: from, to: to, filter: filter, page: page, limit: limit)
        )
    }
    
    func getSalesTotals(from: String, to: String, filter: SalesFilter) async throws -> SalesTotalsResponse {
        try await networkService.request(SalesEndpoint.totals(from: from, to: to, filter: filter))
    }
    
    func createReturn(saleId: Int, request: CreateReturnRequest) async throws -> SaleReturnResponse {
        try await networkService.request(SalesEndpoint.createReturn(saleId: saleId, request: request))
    }
    
    func getSale(id: Int) async throws -> SaleResponse {
        try await networkService.request(SalesEndpoint.sale(id: id))
    }
}
