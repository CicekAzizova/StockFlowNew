//
//  CreateSaleResponse.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//

import Foundation

struct CreateSaleResponse: Decodable {
    let message: String
    let saleId: Int
    let totalPrice: Double
    var sale: SaleResponse? = nil

}
