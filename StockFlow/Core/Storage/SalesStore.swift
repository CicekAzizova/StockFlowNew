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

    var salesSummary: SalesSummaryResponse?
    var dailySales: DailySalesResponse?

    init(salesRepository: SalesRepository) {
        self.salesRepository = salesRepository
    }

    func reset() {
        salesSummary = nil
        dailySales = nil
    }

    func loadSalesSummary() async throws {
        salesSummary = try await salesRepository.getSalesSummary()
    }

    func loadDailySales(days: Int = 7) async throws {
        dailySales = try await salesRepository.getDailySales(days: days)
    }

    func createCartSale(_ request: CreateCartSaleRequest) async throws -> CreateSaleResponse {
        let response = try await salesRepository.createCartSale(request)
        try? await loadSalesSummary()
        try? await loadDailySales()

        return response
    }
}
