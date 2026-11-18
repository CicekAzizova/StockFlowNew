//
//  ProductStockFilter.swift
//  StockFlow
//
//  Created by Cicek on 30.09.26.
//

import SwiftUI

enum ProductStockFilter: String, CaseIterable {
    case all = "All"
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outStock = "Out of Stock"

    var displayName: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .inStock: "In Stock"
        case .lowStock: "Low Stock"
        case .outStock: "Out of Stock"
        }
    }
    
    /// Serverin `stock` parametri. `all` üçün göndərilmir.
    var apiValue: String? {
        switch self {
        case .all: nil
        case .inStock: "in"
        case .lowStock: "low"
        case .outStock: "out"
        }
    }
}
