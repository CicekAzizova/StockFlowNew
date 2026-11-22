//
//  StockMovement.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import Foundation

/// Qalıq hərəkətinin növü. Naməlum yeni növ gələrsə `unknown` olur, decoding sınmır.
enum StockMovementType: String, Decodable, Hashable {
    case initial
    case sale
    case restock
    case transferIn = "transfer_in"
    case transferOut = "transfer_out"
    case adjustment
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = StockMovementType(rawValue: raw) ?? .unknown
    }
}

/// Məhsulun tarixçəsində bir sətir (GET /products/:id/history).
struct StockMovement: Decodable, Identifiable, Hashable {
    let id: Int
    let type: StockMovementType
    let quantityChange: Int
    let balanceAfter: Int?
    let locationId: Int
    let locationName: String
    let relatedLocationName: String?
    let userName: String?
    let receiptNo: Int?
    let note: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, type, note
        case quantityChange = "quantity_change"
        case balanceAfter = "balance_after"
        case locationId = "location_id"
        case locationName = "location_name"
        case relatedLocationName = "related_location_name"
        case userName = "user_name"
        case receiptNo = "receipt_no"
        case createdAt = "created_at"
    }
}
