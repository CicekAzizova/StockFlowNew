//
//  SellerResponse.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

struct SellerResponse: Decodable, Hashable {
    let id: Int
    let name: String
    let surname: String
    let fin: String
    let email: String
    let phone: String
    let role: String
    let storeId: Int
    let createdAt: String
    let todaySales: Double
    let totalSalesThisMonth: Double
    let avatarUrl: String?
    let todayOrders: Int?
    let monthSales: Double?
    let monthOrders: Int?
    let isActive: Bool?
    let isOnline: Bool?
    /// Backend formatı: UTC, "yyyy-MM-dd HH:mm:ss".
    let lastActiveAt: String?

    /// Backend göndərmirsə (köhnə versiya), satıcı aktiv sayılır.
    var isDeactivated: Bool { isActive == false }

    var isCurrentlyOnline: Bool { isOnline == true }

    var lastActiveDate: Date? {
        guard let lastActiveAt else { return nil }
        return Self.lastActiveFormatter.date(from: lastActiveAt)
    }

    private static let lastActiveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, name, surname, fin, email, phone, role
        case storeId = "store_id"
        case createdAt = "created_at"
        case todaySales = "today_sales"
        case totalSalesThisMonth = "total_sales_this_month"
        case avatarUrl = "avatar_url"
        case todayOrders = "today_orders"
        case monthSales = "month_sales"
        case monthOrders = "month_orders"
        case isActive = "is_active"
        case isOnline = "is_online"
        case lastActiveAt = "last_active_at"
    }
}
