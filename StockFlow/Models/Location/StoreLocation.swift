//
//  StoreLocation.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

enum LocationKind: String, Codable, CaseIterable {
    case store
    case warehouse
}

/// Mağazanın məkanı: satış nöqtəsi və ya anbar (GET/POST/PATCH /locations cavabı).
struct StoreLocation: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let kind: LocationKind
    let address: String
    let isMain: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, kind, address
        case isMain = "is_main"
    }
}

struct CreateLocationRequest: Encodable {
    let name: String
    let kind: LocationKind
    var address: String = ""
    var isMain: Bool = false

    enum CodingKeys: String, CodingKey {
        case name, kind, address
        case isMain = "is_main"
    }
}

/// Yalnız dolu sahələr göndərilir. `isMain` yalnız true ola bilər (əsas etmək üçün).
struct UpdateLocationRequest: Encodable {
    var name: String? = nil
    var address: String? = nil
    var isMain: Bool? = nil

    enum CodingKeys: String, CodingKey {
        case name, address
        case isMain = "is_main"
    }
}
