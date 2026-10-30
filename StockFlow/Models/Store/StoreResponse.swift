//
//  StoreResponse.swift
//  StockFlow
//
//  Created by Cicek on 23.09.26.
//

import Foundation

struct StoreResponse: Decodable {
    
    let id: Int
    let name: String
    let email: String
    let phone: String
    let storeName: String
    let storeAddress: String
    let storePhone: String
    let createdAt: String
    let token: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case storeName = "store_name"
        case storeAddress = "store_address"
        case storePhone = "store_phone"
        case createdAt = "created_at"
        case token
        case refreshToken = "refresh_token"
    }
}
