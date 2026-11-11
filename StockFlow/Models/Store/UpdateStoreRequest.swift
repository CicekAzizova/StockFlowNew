//
//  UpdateStoreRequest.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

/// Mağazanı dəyişmək üçün sorğu. Hələ yalnız valyuta.
struct UpdateStoreRequest: Encodable {
    let currency: String
}
