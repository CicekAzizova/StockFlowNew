//
//  SalesStore.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//
import Foundation

@Observable
@MainActor

final class SalesStore {
    private let salesRepository: SalesRepository
    
    private var currentSalesPage = 1
    private var hasMoreSales = true
    var isLoadingMoreSales = false
    var isLoading: Bool = false
    var totalSales = 0
    
    private var salesPageSize = 10

    var recentSales: [SaleResponse] = []
    
    var salesSummary: SalesSummaryResponse?
    
    var dailySales: DailySalesResponse?
    
    init(salesRepository: SalesRepository) {
        self.salesRepository = salesRepository
    }
    
    func reset() {
        recentSales = []
        salesSummary = nil
        dailySales = nil
        totalSales = 0
        currentSalesPage = 1
        hasMoreSales = true
    }
  
    func loadRecentSales(limit: Int = 10) async throws {
        isLoading = true
        salesPageSize = limit
        currentSalesPage = 1
        hasMoreSales = true
        
        defer {
            isLoading = false
        }
        
        let response = try await salesRepository.getRecentSales(
                page: currentSalesPage,
                limit: limit
            )
            
            recentSales = response.items
            totalSales = response.total
            hasMoreSales = response.hasNext
            
    }
    
    func loadMoreSales() async throws {
        guard hasMoreSales else { return }
        guard !isLoadingMoreSales else { return }
        
        isLoadingMoreSales = true
        
        defer {
            isLoadingMoreSales = false
        }

            let nextPage = currentSalesPage + 1
            let response = try await salesRepository.getRecentSales(
                page: nextPage,
                limit: salesPageSize
            )
            
            recentSales.append(contentsOf: response.items)
            currentSalesPage = response.page
            hasMoreSales = response.hasNext
      
    }
    
    func refresh() async throws {
       try await loadRecentSales(limit: salesPageSize)
    }
    
    
    func loadSalesSummary() async throws {
        salesSummary = try await salesRepository.getSalesSummary()
    }
    
    func loadDailySales(days: Int = 7) async throws {
            dailySales = try await salesRepository.getDailySales(days: days)
        }
    
    func createSale(productId: Int, quantity: Int) async throws -> CreateSaleResponse {
        let response = try await salesRepository.createSale(
            CreateSaleRequest(productId: productId, quantity: quantity)
        )
        try? await loadRecentSales(limit: salesPageSize)
        try? await loadSalesSummary()
        try? await loadDailySales()

        return response
    }
}
