//
//  StockTransfer.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

struct TransferItemRequest: Encodable {
    let productId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case quantity
        case productId = "product_id"
    }
}

struct CreateTransferRequest: Encodable {
    let fromLocationId: Int
    let toLocationId: Int
    let items: [TransferItemRequest]
    var note: String? = nil

    enum CodingKeys: String, CodingKey {
        case items, note
        case fromLocationId = "from_location_id"
        case toLocationId = "to_location_id"
    }
}

struct TransferItem: Decodable, Hashable {
    let productId: Int?
    let productName: String
    let sku: String
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case sku, quantity
        case productId = "product_id"
        case productName = "product_name"
    }
}

struct StockTransfer: Decodable, Identifiable, Hashable {
    let id: Int
    let fromLocationName: String
    let toLocationName: String
    let createdByName: String
    let note: String?
    let createdAt: String
    let items: [TransferItem]

    enum CodingKeys: String, CodingKey {
        case id, note, items
        case fromLocationName = "from_location_name"
        case toLocationName = "to_location_name"
        case createdByName = "created_by_name"
        case createdAt = "created_at"
    }
}
