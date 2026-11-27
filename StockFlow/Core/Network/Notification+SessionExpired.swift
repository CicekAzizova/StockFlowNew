//
//  Notification+Session.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

import Foundation

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}

extension Notification.Name {
    static let activeLocationChanged = Notification.Name("activeLocationChanged")
    static let locationsChanged = Notification.Name("locationsChanged")
}

extension Notification.Name {
    /// Qaytarmadan sonra satış siyahısı yenilənsin.
    static let saleChanged = Notification.Name("saleChanged")
}
