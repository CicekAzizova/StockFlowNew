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
    
    
    enum CodingKeys: String, CodingKey {
        case name, sku, description, price, discount, quantity, subcategory
        case costPrice = "cost_price"
        case lowStockLimit = "low_stock_limit"
        case imageUrls = "image_urls"
    }
}
