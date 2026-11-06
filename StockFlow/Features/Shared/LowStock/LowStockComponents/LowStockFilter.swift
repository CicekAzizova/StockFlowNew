//
//  LowStockFilter.swift
//  StockFlow
//
//  Created by Cicek on 06.11.26.
//

import SwiftUI

/// Az qalan ekranındakı çiplər: Hamısı / Bitib / Az.
enum LowStockFilter: CaseIterable, Identifiable {
    case all
    case outOfStock
    case low

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .outOfStock: "Out of stock"
        case .low: "Low"
        }
    }

    /// Məhsul bu çipə uyğundurmu?
    func matches(_ product: ProductsResponse) -> Bool {
        switch self {
        case .all: true
        case .outOfStock: product.stockStatus == .outOfStock
        case .low: product.stockStatus == .lowStock
        }
    }
}
