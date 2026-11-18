//
//  ProductStats.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

/// Məhsulların qalıq üzrə sayları (filtr çipləri üçün).
struct ProductStats: Decodable {
    let total: Int
    let inStock: Int
    let lowStock: Int
    let outOfStock: Int

    enum CodingKeys: String, CodingKey {
        case total
        case inStock = "in_stock"
        case lowStock = "low_stock"
        case outOfStock = "out_of_stock"
    }
}
