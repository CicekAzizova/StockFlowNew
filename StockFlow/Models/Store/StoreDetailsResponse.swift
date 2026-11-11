//
//  StoreDetailsResponse.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

/// Cari mağazanın məlumatı (GET/PATCH /stores/current cavabı).
struct StoreDetailsResponse: Decodable {
    let id: Int
    let name: String
    let address: String
    let phone: String
    let timezone: String
    let currency: String
}
