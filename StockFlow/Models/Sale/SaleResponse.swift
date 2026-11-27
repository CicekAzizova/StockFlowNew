//
//  SaleResponse.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import Foundation

nonisolated struct SaleItemResponse: Decodable, Hashable {
    let id: Int
    let sku: String
    let productId: Int
    let productName: String
    let quantity: Int
    let lineTotal: Double
    var returnedQuantity: Int = 0

    /// Qaytarıla bilən qalıq.
    var returnableQuantity: Int { quantity - returnedQuantity }

    enum CodingKeys: String, CodingKey {
        case id, quantity, sku
        case productId = "product_id"
        case productName = "product_name"
        case lineTotal = "line_total"
        case returnedQuantity = "returned_quantity"
    }
}

enum PaymentMethod: String {
    case cash, card, transfer, other, mixed
}

nonisolated struct SaleResponse: Decodable, Hashable {
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
    var returnedAmount: Double = 0
    var payments: [SalePaymentResponse]? = nil

    /// Ödəniş üsulu. Naməlum dəyər "other" sayılır.
    var paymentMethod: PaymentMethod {
        PaymentMethod(rawValue: paymentMethodRaw ?? "") ?? .other
    }

    /// Satışdakı ümumi məhsul sayı.
    var itemsCount: Int {
        items?.reduce(0) { $0 + $1.quantity } ?? quantity
    }
    
    /// Satışın bir hissəsi və ya hamısı qaytarılıb.
    var isReturned: Bool { returnedAmount > 0 }

    /// Qaytarmadan sonra qalan məbləğ.
    var netTotal: Double { max(totalPrice - returnedAmount, 0) }

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
        case returnedAmount = "returned_amount"
        case items
        case payments
    }
}

nonisolated struct SalePaymentResponse: Decodable, Hashable {
    let method: String
    let amount: Double

    var paymentMethod: PaymentMethod { PaymentMethod(rawValue: method) ?? .other }
}
