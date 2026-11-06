//
//  HomeViewModel.swift
//  StockFlow
//
//  Created by Cicek on 02.10.26.
//

import Foundation

@Observable
@MainActor

final class HomeViewModel {
    
    private let productStore: ProductsStore
    private let salesStore: SalesStore
    /// Yalnız owner üçün verilir. nil olsa, satıcı sayı yüklənmir.
    private let sellerRepository: SellerRepository?
    
    var state: HomeViewState = .idle
    
    /// Satıcıların sayı. Owner olmayanda nil.
    private(set) var associatesCount: Int?
    
    init(productStore: ProductsStore,
         salesStore: SalesStore,
         sellerRepository: SellerRepository? = nil
    ) {
        self.productStore = productStore
        self.salesStore = salesStore
        self.sellerRepository = sellerRepository
    }
    
    func loadHome() async {
        let previousState = state
        
        if !state.isLoaded {
            state = .loading
        }
        
        do   {
            async let loadProducts: () = loadProducts()
            async let loadLowStock: () = loadLowStock()
            async let loadRecentSales: () = loadRecentSales()
            async let loadSalesSummary: () = loadSalesSummary()
            async let loadAssociatesCount: () = loadAssociatesCount()
            async let loadDailySales: () = loadDailySales()
            
            
            _ = try await (
                loadProducts,
                loadLowStock,
                loadRecentSales,
                loadSalesSummary,
                loadAssociatesCount,
                loadDailySales
            )
            
            state = .loaded
        }
        catch is CancellationError {
            state = previousState
        }
        catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func loadProducts() async throws {
        try await productStore.loadProducts(limit: 5)
    }
    
    func loadLowStock() async throws {
        try await productStore.loadLowStock(limit: 5)
    }
    
    func loadRecentSales() async throws {
        try await salesStore.loadRecentSales(limit: 5)
    }
    
    func loadSalesSummary() async throws {
        try await salesStore.loadSalesSummary()
    }
    
    func loadDailySales() async {
        try? await salesStore.loadDailySales(days: 7)
    }
    
    /// Satıcı sayı kritik deyil: yüklənməsə, bütün Home xəta göstərməsin.
    func loadAssociatesCount() async {
        guard let sellerRepository else { return }
        if let sellers = try? await sellerRepository.getSellers() {
            associatesCount = sellers.count
        }
    }
    
    func refresh() async {
        await loadHome()
    }
    
    var productsCount: Int {
        productStore.productsCount
    }
    
    var lowStockCount: Int {
        productStore.lowStockCount
    }
    
    var lowStockProducts: [ProductsResponse] {
        Array(productStore.lowStockProducts.prefix(5))
    }
    
    var recentSales: [SaleResponse] {
        Array(salesStore.recentSales.prefix(5))
    }
    
    var revenue: Double {
        salesStore.salesSummary?.totalSales ?? 0
    }
    
    var todaySales: Double {
        salesStore.salesSummary?.todaySales ?? 0
    }
    
    var todayOrders: Int {
        salesStore.salesSummary?.todayOrders ?? 0
    }
    
    /// Son 7 gün (qrafik üçün).
    var weeklySales: [DailySales] {
        salesStore.dailySales?.days ?? []
    }
    
    /// Dünənki satış. Məlumat yoxdursa nil.
    var yesterdaySales: Double? {
        let days = weeklySales
        guard days.count >= 2 else { return nil }
        return days[days.count - 2].total
    }
    
    /// Bu gün − dünən. Müsbət = artım, mənfi = azalma.
    var differenceFromYesterday: Double? {
        guard let yesterdaySales else { return nil }
        return todaySales - yesterdaySales
    }
    
}
