//
//  PreviewSupport.swift
//  StockFlow
//
//  Created by Cicek on 16.10.26.
//

#if DEBUG
import Foundation

// MARK: - Sample data

enum PreviewError: LocalizedError {
    case failed
    var errorDescription: String? { "Could not load data. Please try again." }
}

enum PreviewData {

    static let owner = User(
        id: 1,
        email: "owner@stockflow.com",
        name: "Cicek",
        role: .owner,
        storeName: "Demo Store"
    )

    static let seller = User(
        id: 2,
        email: "seller@stockflow.com",
        name: "Seller",
        role: .seller,
        storeName: "Demo Store"
    )

    static let products: [ProductsResponse] = [
        product(id: 1, name: "Wireless Mouse", sku: "WM-1001", price: 24.99, discount: 10, quantity: 40),
        product(id: 2, name: "USB-C Cable", sku: "UC-2002", price: 9.99, quantity: 3),
        product(id: 3, name: "Mechanical Keyboard", sku: "MK-3003", price: 89.00, quantity: 0)
    ]

    static let sales: [SaleResponse] = [
        sale(id: 1, name: "Wireless Mouse", quantity: 2, unitPrice: 22.49),
        sale(id: 2, name: "USB-C Cable", quantity: 5, unitPrice: 9.99)
    ]

    static let summary = SalesSummaryResponse(
        todaySales: 94.93, todayOrders: 2, totalSales: 1250.50, totalOrders: 37
    )

    static func product(
        id: Int, name: String, sku: String, price: Double,
        discount: Double = 0, quantity: Int, lowStockLimit: Int = 5
    ) -> ProductsResponse {
        ProductsResponse(
            id: id, name: name, sku: sku, category: "Electronics",
            description: "Sample product", price: price, discount: discount,
            costPrice: price / 2, quantity: quantity, lowStockLimit: lowStockLimit,
            imageUrls: nil, createdAt: "2026-10-01"
        )
    }

    static func sale(id: Int, name: String, quantity: Int, unitPrice: Double) -> SaleResponse {
        SaleResponse(
            id: id, productId: id, productName: name, quantity: quantity,
            unitPrice: unitPrice, totalPrice: unitPrice * Double(quantity),
            soldBy: 2, sellerName: "Seller", createdAt: .now
        )
    }

    static func page<T: Decodable>(_ items: [T]) -> PaginationResponse<T> {
        PaginationResponse(items: items, page: 1, limit: 10, total: items.count, hasNext: false)
    }
}

// MARK: - Preview repositories

/// `result` nəticəni, `delay` isə uzun yüklənmə (Loading) halını simulyasiya edir.
struct PreviewProductRepository: ProductRepository {
    func setStock(id: Int, quantity: Int, locationId: Int) async throws {}
    
    func restockProduct(id: Int, quantity: Int, locationId: Int?) async throws -> ProductsResponse {
        throw PreviewError.failed
    }
    
    func getProducts(page: Int, limit: Int, query: String?, stock: String?) async throws -> PaginationResponse<ProductsResponse> {
        PreviewData.page(try await items())

    }
    
    func getProductHistory(id: Int, page: Int, limit: Int) async throws -> PaginationResponse<StockMovement> {
        PaginationResponse(items: [], page: 1, limit: limit, total: 0, hasNext: false)
    }

    func setForSale(id: Int, forSale: Bool) async throws -> ProductsResponse {
        throw PreviewError.failed
    }
    
    func getProductStats() async throws -> ProductStats {
        throw PreviewError.failed

    }
    
    var result: Result<[ProductsResponse], Error> = .success(PreviewData.products)
    var delay: Duration?

    private func items() async throws -> [ProductsResponse] {
        if let delay { try await Task.sleep(for: delay) }
        return try result.get()
    }

    func getProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse> {
        PreviewData.page(try await items())
    }

    func getLowStockProducts(page: Int, limit: Int) async throws -> PaginationResponse<ProductsResponse> {
        PreviewData.page(try await items().filter { $0.stockStatus != .inStock })
    }

    func createProduct(_ request: ProductRequest) async throws -> ProductsResponse { throw PreviewError.failed }
    func getProduct(bySku sku: String) async throws -> ProductsResponse { throw PreviewError.failed }
    func updateProduct(id: Int, request: ProductRequest) async throws -> ProductsResponse { throw PreviewError.failed }
    func deleteProduct(id: Int) async throws {}
}


struct PreviewReportRepository: ReportRepository {
    func getSalesReport(period: ReportPeriod, year: Int?, locationId: Int?) async throws -> SalesReport {
        let buckets: [ReportBucket]
        if period == .year {
            let shownYear = year ?? 2026
            let yearBonus = (shownYear - 2020) * 30
            var months: [ReportBucket] = []

            for month in 1...12 {
                let revenue: Double = Double(month * 90 + yearBonus)
                let profit: Double = Double(month * 27)
                let label = "\(shownYear)-" + String(format: "%02d", month)

                months.append(
                    ReportBucket(
                        label: label,
                        revenue: revenue,
                        profit: profit,
                        orders: month + 2,
                        itemsSold: month * 2
                    )
                )
            }
            buckets = months
        } else {
            buckets = (0..<7).map { i in
                ReportBucket(
                    label: "2026-11-\(String(format: "%02d", 17 + i))",
                    revenue: Double(100 + i * 40),
                    profit: Double(30 + i * 12),
                    orders: 3 + i,
                    itemsSold: 6 + i * 2
                )
            }
        }
        return SalesReport(
            period: period.rawValue,
            firstYear: 2024,
            from: "2026-11-17",
            to: "2026-11-23",
            revenue: 1540,
            profit: 462,
            orders: 42,
            itemsSold: 90,
            unknownCostRevenue: 120,
            previous: ReportTotals(revenue: 1300, profit: 480, orders: 38, itemsSold: 80),
            byLocation: [
                ReportLocationSales(locationId: 1, name: "Nərimanov", revenue: 1000, profit: 300, orders: 25),
                ReportLocationSales(locationId: 2, name: "Gənclik", revenue: 540, profit: 162, orders: 17)
            ],
            buckets: buckets
        )
    }
}
struct PreviewSalesRepository: SalesRepository {
    func createCartSale(_ request: CreateCartSaleRequest) async throws -> CreateSaleResponse {
        throw PreviewError.failed
    }
    
    func getSalesInRange(
        from: String,
        to: String,
        sellerId: Int?,
        page: Int,
        limit: Int
    ) async throws -> PaginationResponse<SaleResponse> {
        if fails { throw PreviewError.failed }
        if empty { return PreviewData.page([]) }
        return PreviewData.page([
            PreviewData.sale(id: 1042, name: "Süd 1L", quantity: 3, unitPrice: 2.35),
            PreviewData.sale(id: 1041, name: "Mineral su", quantity: 1, unitPrice: 0.6),
            PreviewData.sale(id: 1040, name: "Düyü 1kg", quantity: 6, unitPrice: 3.1)
        ])
    }

    func getSalesTotals(from: String, to: String, sellerId: Int?) async throws -> SalesTotalsResponse {
        if fails { throw PreviewError.failed }
        return SalesTotalsResponse(
            from: from,
            to: to,
            revenue: 1245.8,
            orders: 38,
            averageCheck: 32.78,
            previous: SalesTotals(revenue: 1100, orders: 34, averageCheck: 32.35),
            bySeller: [
                SellerTotals(sellerId: 2, sellerName: "Rəşad M.", revenue: 800, orders: 20),
                SellerTotals(sellerId: 3, sellerName: "Leyla H.", revenue: 445.8, orders: 18)
            ], byPayment: [PaymentTotal(method: "card", amount: 20)]
        )
    }
    
    func getDailySales(days: Int) async throws -> DailySalesResponse {
        if fails { throw PreviewError.failed }
        if empty { return DailySalesResponse(days: [], total: 0, orders: 0) }
        return DailySalesResponse(
            days: [
                DailySales(date: "2026-10-30", total: 320, orders: 5),
                DailySales(date: "2026-10-31", total: 540, orders: 8),
                DailySales(date: "2026-11-01", total: 210, orders: 3),
                DailySales(date: "2026-11-02", total: 760, orders: 11),
                DailySales(date: "2026-11-03", total: 430, orders: 6),
                DailySales(date: "2026-11-04", total: 980, orders: 12),
                DailySales(date: "2026-11-05", total: 1125, orders: 14)
            ],
            total: 4365,
            orders: 59
        )
    }
    
    var fails = false
    var empty = false

    func getSalesSummary() async throws -> SalesSummaryResponse {
        if fails { throw PreviewError.failed }
        if empty { return SalesSummaryResponse(todaySales: 0, todayOrders: 0, totalSales: 0, totalOrders: 0) }
        return PreviewData.summary
    }

    func getSales(sellerId: Int, page: Int, limit: Int) async throws -> PaginationResponse<SaleResponse> {
        if fails { throw PreviewError.failed }
        if empty { return PreviewData.page([]) }
        return PreviewData.page(PreviewData.sales)
    }
}

struct PreviewTokenStorage: TokenStoring {
    func saveToken(_ token: String) throws {}
    func readToken() throws -> String? { nil }
    func deleteToken() throws {}
    func saveRefreshToken(_ token: String) throws {}
    func readRefreshToken() throws -> String? { nil }
    func deleteRefreshToken() throws {}
}

struct PreviewUserRepository: UserRepository {
    func getUser() async throws -> User { PreviewData.owner }

    func updateProfile(name: String, surname: String, phone: String) async throws -> User {
        PreviewData.owner
    }

    func uploadAvatar(_ imageData: Data) async throws -> User {
        PreviewData.owner
    }

    func deleteAvatar() async throws -> User {
        PreviewData.owner
    }

    func changePassword(current: String, new: String) async throws {}

    func deleteAccount(password: String) async throws {}
}

struct PreviewAuthRepository: AuthRepository {
    func forgotPassword(email: String) async throws {
        throw PreviewError.failed

    }
    
    func resetPassword(email: String, code: String, newPassword: String) async throws {
        throw PreviewError.failed

    }
    
    func verifyEmail(code: String) async throws {
        throw PreviewError.failed

    }
    
    func resendVerification() async throws {
        throw PreviewError.failed

    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        throw PreviewError.failed
    }
    func logout(refreshToken: String) async {}
}

struct PreviewStoreRepository: StoreRepository {
    func updateStore(_ request: UpdateStoreRequest) async throws -> StoreDetailsResponse {
        throw PreviewError.failed
    }
    
    func createStore(_ request: StoreRequest) async throws -> StoreResponse {
        throw PreviewError.failed
    }
    
    func updateCurrency(_ currency: String) async throws -> StoreDetailsResponse {
        throw PreviewError.failed
    }
}

struct PreviewImageUploadRepository: ImageUploadRepository {
    func uploadImage(_ imageData: Data) async throws -> String {
        throw PreviewError.failed
    }
}

struct PreviewCatalogRepository: CatalogRepository {
    func getCategories() async throws -> [CatalogCategory] {
        throw PreviewError.failed
    }
}

struct PreviewLocationRepository: LocationRepository {
    func deleteLocation(id: Int) async throws {}
    
    func getLocations() async throws -> [StoreLocation] {
        [
            StoreLocation(id: 1, name: "Main store", kind: .store, address: "Baku", isMain: true),
            StoreLocation(id: 2, name: "Central warehouse", kind: .warehouse, address: "", isMain: false)
        ]
    }

    func createLocation(_ request: CreateLocationRequest) async throws -> StoreLocation {
        StoreLocation(id: 3, name: request.name, kind: request.kind, address: request.address, isMain: request.isMain)
    }

    func updateLocation(id: Int, _ request: UpdateLocationRequest) async throws -> StoreLocation {
        StoreLocation(id: id, name: request.name ?? "Location", kind: .store, address: request.address ?? "", isMain: request.isMain ?? false)
    }
    
    
}
struct PreviewTransferRepository: TransferRepository {
    func createTransfer(_ request: CreateTransferRequest) async throws -> StockTransfer {
        StockTransfer(
            id: 1,
            fromLocationName: "Central warehouse",
            toLocationName: "Main store",
            createdByName: "Owner",
            note: nil,
            createdAt: "2026-11-17 12:00:00",
            items: []
        )
    }
}
struct PreviewSellerRepository: SellerRepository {
    func deactivateSeller(id: Int) async throws -> SellerResponse {
        throw PreviewError.failed
    }
    
    func activateSeller(id: Int) async throws -> SellerResponse {
        throw PreviewError.failed
    }
    
    func updateSeller(id: Int, request: UpdateSellerRequest) async throws -> SellerResponse {
        throw PreviewError.failed
    }
    
    func addSeller(request: SellerRequest) async throws -> SellerResponse {
        throw PreviewError.failed
    }
    
    func getSellers() async throws -> [SellerResponse] { [] }
    
    func deleteSeller(id: Int) async throws {}
}

// MARK: - Preview AppDependencies

extension AppDependencies {
    @MainActor
    static func preview(
        productResult: Result<[ProductsResponse], Error>? = nil,
        salesFails: Bool = false,
        salesEmpty: Bool = false
    ) -> AppDependencies {
        AppDependencies(
            tokenStorage: PreviewTokenStorage(),
            authRepository: PreviewAuthRepository(),
            storeRepository: PreviewStoreRepository(),
            userRepository: PreviewUserRepository(),
            productRepository: PreviewProductRepository(result: productResult ?? .success(PreviewData.products)),
            imageUploadRepository: PreviewImageUploadRepository(),
            sellerRepository: PreviewSellerRepository(),
            salesRepository: PreviewSalesRepository(fails: salesFails, empty: salesEmpty)
        )
    }
}
#endif
