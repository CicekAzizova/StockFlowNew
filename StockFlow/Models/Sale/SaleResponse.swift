//
//  SaleResponse.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import Foundation

struct SaleItemResponse: Decodable, Hashable {
    let productName: String
    let quantity: Int
    let lineTotal: Double

    enum CodingKeys: String, CodingKey {
        case quantity
        case productName = "product_name"
        case lineTotal = "line_total"
    }
}

enum PaymentMethod: String {
    case cash, card, transfer, other, mixed
}

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
    var sellerAvatarUrl: String? = nil
    var locationName: String? = nil
    var receiptNo: Int? = nil
    var paymentMethodRaw: String? = nil
    var items: [SaleItemResponse]? = nil

    /// Ödəniş üsulu. Naməlum dəyər "other" sayılır.
    var paymentMethod: PaymentMethod {
        PaymentMethod(rawValue: paymentMethodRaw ?? "") ?? .other
    }

    /// Satışdakı ümumi məhsul sayı.
    var itemsCount: Int {
        items?.reduce(0) { $0 + $1.quantity } ?? quantity
    }

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
        case sellerAvatarUrl = "seller_avatar_url"
        case locationName = "location_name"
        case receiptNo = "receipt_no"
        case paymentMethodRaw = "payment_method"
        case items
    }
}
