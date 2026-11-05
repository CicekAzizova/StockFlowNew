//
//  SaleResponse.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import Foundation

struct SaleResponse: Decodable, Hashable {
    let id: Int
    let productId: Int
    let productName: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    let soldBy: Int?
    let sellerName: String?
    let createdAt: Date
    var productImageUrl: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case productName = "product_name"
        case quantity
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
        case soldBy = "sold_by"
        case sellerName = "seller_name"
        case createdAt = "created_at"
        case productImageUrl = "product_image_url"

    }
}


