//
//  ProductsRequest.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import Foundation

struct ProductRequest: Encodable {
    let name: String
    let sku: String
    let description: String
    let price: Double
    let discount: Double
    let costPrice: Double
    let quantity: Int
    let lowStockLimit: Int
    var subcategory: String?
    var imageUrls: [String]?
    var unit: ProductUnit = .piece
    var weight: Double?
    var weightUnit: String?
    var size: String?
    var stocks: [InitialStock]?
    
    
    enum CodingKeys: String, CodingKey {
        case name, sku, description, price, discount, quantity, subcategory, unit, weight, size, stocks
        case costPrice = "cost_price"
        case lowStockLimit = "low_stock_limit"
        case imageUrls = "image_urls"
        case weightUnit = "weight_unit"
    }
}
/// Yaradanda bir məkana yazılan başlanğıc qalıq.
struct InitialStock: Encodable {
    let locationId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case quantity
        case locationId = "location_id"
    }
}
