//
//  ProductsResponse.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import Foundation

/// Məhsulun bir məkandakı qalığı.
struct ProductStock: Decodable, Hashable, Identifiable {
    let locationId: Int
    let locationName: String
    let quantity: Int

    var id: Int { locationId }

    enum CodingKeys: String, CodingKey {
        case quantity
        case locationId = "location_id"
        case locationName = "location_name"
    }
}

struct ProductsResponse: Decodable, Hashable {
    let id: Int
    let name: String
    let sku: String
    let category: String
    let description: String
    let price: Double
    let discount: Double
    let costPrice: Double
    let quantity: Int
    let lowStockLimit: Int
    let imageUrls: [String]?
    let createdAt: String
    var soldThisMonth: Int = 0
    var subcategory: String? = nil
    var stocks: [ProductStock] = []
    var unit: ProductUnit? = nil
    var weight: Double? = nil
    var weightUnit: String? = nil
    var size: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name, sku, category, description, price, discount, quantity, subcategory, stocks,unit, weight, size
        case costPrice = "cost_price"
        case lowStockLimit = "low_stock_limit"
        case createdAt = "created_at"
        case imageUrls = "image_urls"
        case soldThisMonth = "sold_this_month"
        case weightUnit = "weight_unit"
        
    }
}

extension ProductsResponse {
    var stockStatus: StockStatus {
        if quantity == 0 {
            return .outOfStock
        } else if quantity <= lowStockLimit {
            return .lowStock
        } else {
            return .inStock
        }
    }
    
    var discountedPrice: Double {
        (price * (100 - discount)).rounded() / 100
    }

    var hasDiscount: Bool { discount > 0 }
}
