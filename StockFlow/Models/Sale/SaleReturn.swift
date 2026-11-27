//
//  SaleReturn.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import Foundation

enum ReturnReason: String, CaseIterable, Hashable {
    case damaged
    case customerDeclined = "customer_declined"
    case wrongItem = "wrong_item"
    case other
}

struct ReturnItemRequest: Encodable {
    let saleItemId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case quantity
        case saleItemId = "sale_item_id"
    }
}

struct CreateReturnRequest: Encodable {
    let items: [ReturnItemRequest]
    let reason: String
    /// Pul necə qaytarıldı: nağd, kart, köçürmə.
    let refundMethod: String
    /// Mal qalığa qayıtsın (zədəli mal üçün false).
    let restock: Bool

    enum CodingKeys: String, CodingKey {
        case items, reason, restock
        case refundMethod = "refund_method"
    }
}

nonisolated struct SaleReturnResponse: Decodable {
    let id: Int
    let saleId: Int
    let totalAmount: Double
    let restocked: Bool

    enum CodingKeys: String, CodingKey {
        case id, restocked
        case saleId = "sale_id"
        case totalAmount = "total_amount"
    }
}
