//
//  RestockRequest.swift
//  StockFlow
//
//  Created by Cicek on 06.11.26.
//

import Foundation

/// Qalığa əlavə olunacaq ədəd sayı (serverdə toplanır).
struct RestockRequest: Encodable {
    let quantity: Int
}
