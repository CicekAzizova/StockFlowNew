//
//  AddProductFocusedField.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import Foundation

enum AddProductFocusedField: Hashable, CaseIterable {
    case name
    case sku
    case description
    case price
    case discount
    case costPrice
    case quantity
    case lowStockLimit
}
