//
//  SalesTotals.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

struct SalesTotals: Decodable {
    let revenue: Double
    let orders: Int
    let averageCheck: Double

    enum CodingKeys: String, CodingKey {
        case revenue, orders
        case averageCheck = "average_check"
    }
}

struct SellerTotals: Decodable, Identifiable {
    let sellerId: Int
    let sellerName: String
    let revenue: Double
    let orders: Int

    var id: Int { sellerId }

    enum CodingKeys: String, CodingKey {
        case revenue, orders
        case sellerId = "seller_id"
        case sellerName = "seller_name"
    }
}

struct SalesTotalsResponse: Decodable {
    let from: String
    let to: String
    let revenue: Double
    let orders: Int
    let averageCheck: Double
    /// Əvvəlki eyni uzunluqlu dövr (faiz müqayisəsi üçün).
    let previous: SalesTotals
    let bySeller: [SellerTotals]
    let byPayment: [PaymentTotal]?
    let itemsSold: Int
    let returned: Double

    enum CodingKeys: String, CodingKey {
        case from, to, revenue, orders, previous, returned
        case averageCheck = "average_check"
        case bySeller = "by_seller"
        case byPayment = "by_payment"
        case itemsSold = "items_sold"
    }
}

/// Bir ödəniş növü üzrə daxil olan pul.
nonisolated struct PaymentTotal: Decodable, Hashable {
    let method: String
    let received: Double
    let refunded: Double
    let amount: Double

    var paymentMethod: PaymentMethod { PaymentMethod(rawValue: method) ?? .other }

    enum CodingKeys: String, CodingKey {
        case method, received, refunded, amount
    }
}
