//
//  SellerSalesViewModel.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import Foundation

@Observable
@MainActor

final class SellerSalesViewModel {
    private let salesStore: SalesStore
    
    var state: SalesViewState = .idle
    
    init(salesStore: SalesStore) {
        self.salesStore = salesStore
    }
    
    func loadSales() async {
        let previousState = state
        
        if case .loaded = previousState {
            //
        } else {
            state = .loading
        }
        
        do {
            async let summary: () = salesStore.loadSalesSummary()
            async let sales: () = salesStore.loadRecentSales(limit: 10)
            _ = try await (summary, sales)
            state = .loaded
        }
        catch is CancellationError {
            state = previousState
        }
        catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func refresh() async {
        await loadSales()
    }
    
    var todaySales: Double {
        salesStore.salesSummary?.todaySales ?? 0
    }
    
    var todayOrders: Int {
        salesStore.salesSummary?.todayOrders ?? 0
    }

    var latestSales: [SaleResponse] {
        Array(salesStore.recentSales.prefix(5))
    }
}
