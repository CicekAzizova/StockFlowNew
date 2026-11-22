//
//  ForSaleRequest.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import Foundation

struct ForSaleRequest: Encodable {
    let forSale: Bool

    enum CodingKeys: String, CodingKey {
        case forSale = "for_sale"
    }
}
