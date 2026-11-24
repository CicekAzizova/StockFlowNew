//
//  CreateCartSaleRequest.swift
//  StockFlow
//
//  Created by Cicek on 24.11.26.
//

import Foundation

struct SaleItemRequest: Encodable {
    let productId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case quantity
    }
}

struct SalePaymentRequest: Encodable {
    let method: String
    let amount: Double
}

/// Səbətdən satış: bir neçə məhsul, ödəniş bölgüsü və kassirin endirimi.
struct CreateCartSaleRequest: Encodable {
    let items: [SaleItemRequest]
    let paymentMethod: String
    /// Yalnız qarışıq ödənişdə göndərilir.
    let payments: [SalePaymentRequest]?
    /// Kassirin endirimi manatla (0 olanda göndərilmir).
    let discount: Double?

    enum CodingKeys: String, CodingKey {
        case items, payments, discount
        case paymentMethod = "payment_method"
    }
}
