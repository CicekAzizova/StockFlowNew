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
    let costPrice: Double?
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
    
    /// weight, weightUnit, size və costPrice boşdursa null göndərili ki, server köhnə dəyəri silsin.
    /// (Standart kodlaşdırma boş dəyəri tamamilə buraxır, server isə bunu "dəyişmə" kimi oxuyur.)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(sku, forKey: .sku)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(discount, forKey: .discount)
        try container.encode(costPrice, forKey: .costPrice)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(lowStockLimit, forKey: .lowStockLimit)
        try container.encodeIfPresent(subcategory, forKey: .subcategory)
        try container.encodeIfPresent(imageUrls, forKey: .imageUrls)
        try container.encode(unit, forKey: .unit)
        try container.encodeIfPresent(stocks, forKey: .stocks)

        // Bu üçü boş olsa belə `null` kimi yazılır.
        try container.encode(weight, forKey: .weight)
        try container.encode(weightUnit, forKey: .weightUnit)
        try container.encode(size, forKey: .size)
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
