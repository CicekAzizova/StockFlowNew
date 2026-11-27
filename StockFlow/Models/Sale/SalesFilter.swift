//
//  SalesFilter.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import Foundation

/// Satışlar siyahısının süzgəcləri. Hamısı nil olanda süzgəc yoxdur.
struct SalesFilter: Equatable {
    var sellerId: Int?
    var locationId: Int?
    var paymentMethod: PaymentMethod?

    static let none = SalesFilter()

    /// Neçə süzgəc aktivdir (başlıqdakı nişan üçün).
    var activeCount: Int {
        [sellerId != nil, locationId != nil, paymentMethod != nil].filter { $0 }.count
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let sellerId {
            items.append(URLQueryItem(name: "seller_id", value: String(sellerId)))
        }
        if let locationId {
            items.append(URLQueryItem(name: "location_id", value: String(locationId)))
        }
        if let paymentMethod {
            items.append(URLQueryItem(name: "payment_method", value: paymentMethod.rawValue))
        }
        return items
    }
}
