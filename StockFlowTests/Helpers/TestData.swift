//
//  TestData.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import Foundation
@testable import StockFlow

enum TestError: LocalizedError {
    case failed
    var errorDescription: String? { "Test failure" }
}

@MainActor
enum TestData {

    static let owner = User(
        id: 1,
        email: "owner@stockflow.com",
        name: "Cicek",
        role: .owner,
        storeName: "Test Store"
    )
    static let loginResponse = LoginResponse(user: owner, token: "test_token", refreshToken: "test_refresh_token")

    static func product(
        id: Int = 1,
        name: String = "Apple",
        sku: String = "SKU-1",
        price: Double = 10,
        quantity: Int = 20,
        lowStockLimit: Int = 5
    ) -> ProductsResponse {
        ProductsResponse(
            id: id,
            name: name,
            sku: sku,
            category: "Fruit",
            description: "",
            price: price,
            discount: 0,
            costPrice: 5,
            quantity: quantity,
            lowStockLimit: lowStockLimit,
            imageUrls: nil,
            createdAt: "2026-10-01"
        )
    }

    static func page<T: Decodable>(_ items: [T]) -> PaginationResponse<T> {
        PaginationResponse(items: items, page: 1, limit: 10, total: items.count, hasNext: false)
    }

    static func createSaleResponse(total: Double) -> CreateSaleResponse {
        CreateSaleResponse(message: "ok", saleId: 1, totalPrice: total)
    }
}
