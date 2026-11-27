//
//  ProductFilter.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import Foundation
import SwiftUI

enum ProductSort: String, CaseIterable, Hashable {
    case newest
    case name
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case stockAsc = "stock_asc"
    case stockDesc = "stock_desc"
    case bestSelling = "best_selling"

    var title: LocalizedStringKey {
        switch self {
        case .newest: "Newest"
        case .name: "Name (A–Z)"
        case .priceAsc: "Price: low to high"
        case .priceDesc: "Price: high to low"
        case .stockAsc: "Stock: low to high"
        case .stockDesc: "Stock: high to low"
        case .bestSelling: "Best selling"
        }
    }
}

/// Məhsullar siyahısının əlavə süzgəcləri və sıralaması.
nonisolated struct ProductFilter: Equatable {
    /// Kataloq kodu: "food" bütün alt kateqoriyaları tutur, "food.dairy" yalnız birini.
    var subcategory: String?
    /// nil = hamısı, true = satışda, false = deaktiv.
    var forSale: Bool?
    var sort: ProductSort = .newest

    /// Başlıqdakı nişan üçün: neçə süzgəc aktivdir (sıralama sayılmır).
    var activeCount: Int {
        [subcategory != nil, forSale != nil].filter { $0 }.count
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let subcategory {
            items.append(URLQueryItem(name: "subcategory", value: subcategory))
        }
        if let forSale {
            items.append(URLQueryItem(name: "for_sale", value: forSale ? "true" : "false"))
        }
        if sort != .newest {
            items.append(URLQueryItem(name: "sort", value: sort.rawValue))
        }
        return items
    }
}
