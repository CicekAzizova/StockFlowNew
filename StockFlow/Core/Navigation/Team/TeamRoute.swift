//
//  TeamRoute.swift
//  StockFlow
//
//  Created by Cicek on 04.10.26.
//

enum TeamRoute: Hashable {
    case addSeller
    case sellerDetail(SellerResponse)
    case editSeller(SellerResponse)

}
