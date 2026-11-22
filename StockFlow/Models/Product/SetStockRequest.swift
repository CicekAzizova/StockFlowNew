//
//  SetStockRequest.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

/// Mağazanın qalığını verilən sayla əvəz edir (tarixçədə "Düzəliş" yazılır).
struct SetStockRequest: Encodable {
    let quantity: Int
}
