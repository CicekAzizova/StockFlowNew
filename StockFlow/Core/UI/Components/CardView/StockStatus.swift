//
//  StockStatus.swift
//  StockFlow
//
//  Created by Cicek on 03.10.26.
//

import SwiftUI

enum StockStatus {
    case inStock
    case lowStock
    case outOfStock

    func text(quantity: Int) -> LocalizedStringKey {
        switch self {
        case .inStock:
            return "\(quantity) in stock"
        case .lowStock:
            return "\(quantity) low"
        case .outOfStock:
            return "Out of stock"
        }
    }

    var color: Color {
        switch self {
        case .inStock:
            return .success
        case .lowStock:
            return .pending
        case .outOfStock:
            return .error
        }
    }

    var backgroundColor: Color {
        switch self {
        case .inStock:
            return .success.opacity(0.10)
        case .lowStock:
            return .pending.opacity(0.10)
        case .outOfStock:
            return .error.opacity(0.10)
        }
    }
}

