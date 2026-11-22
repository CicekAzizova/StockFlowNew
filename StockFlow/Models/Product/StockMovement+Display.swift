//
//  StockMovement+Display.swift
//  StockFlow
//
//  Created by Cicek on 22.11.26.
//

import Foundation

extension StockMovement {

    private static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    /// Serverdən gələn mətn vaxtı Date-ə çevirir.
    var date: Date? { Self.parser.date(from: createdAt) }
}
