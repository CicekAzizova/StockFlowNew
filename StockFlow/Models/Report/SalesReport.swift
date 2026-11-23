//
//  SalesReport.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

enum ReportPeriod: String, CaseIterable, Identifiable {
    case week, month, year
    var id: String { rawValue }
}

struct ReportTotals: Decodable {
    let revenue: Double
    let profit: Double
    let orders: Int
    let itemsSold: Int

    enum CodingKeys: String, CodingKey {
        case revenue, profit, orders
        case itemsSold = "items_sold"
    }
}

struct ReportBucket: Decodable, Identifiable {
    let label: String
    let revenue: Double
    let profit: Double
    let orders: Int
    let itemsSold: Int

    var id: String { label }

    enum CodingKeys: String, CodingKey {
        case label, revenue, profit, orders
        case itemsSold = "items_sold"
    }
}

struct ReportLocationSales: Decodable, Identifiable {
    let locationId: Int
    let name: String
    let revenue: Double
    let profit: Double
    let orders: Int

    var id: Int { locationId }

    enum CodingKeys: String, CodingKey {
        case name, revenue, profit, orders
        case locationId = "location_id"
    }
}

struct SalesReport: Decodable {
    let period: String
    /// İlk satışın ili. İl görünüşündə geriyə sürüşdürmənin son həddi.
    let firstYear: Int
    let from: String
    let to: String
    let revenue: Double
    let profit: Double
    let orders: Int
    let itemsSold: Int
    let unknownCostRevenue: Double
    let previous: ReportTotals
    /// Məkanlar üzrə gəlir. Konkret məkan seçiləndə boş olur.
    let byLocation: [ReportLocationSales]
    let buckets: [ReportBucket]

    enum CodingKeys: String, CodingKey {
        case period, from, to, revenue, profit, orders, previous, buckets
        case firstYear = "first_year"
        case itemsSold = "items_sold"
        case unknownCostRevenue = "unknown_cost_revenue"
        case byLocation = "by_location"
    }
}
