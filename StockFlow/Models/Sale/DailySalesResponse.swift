//
//  DailySalesResponse.swift
//  StockFlow
//
//  Created by Cicek on 05.11.26.
//

import Foundation

struct DailySalesResponse: Decodable {
    let days: [DailySales]
    let total: Double
    let orders: Int
}

struct DailySales: Decodable, Identifiable {
    let date: String
    let total: Double
    let orders: Int

    var id: String { date }
}
