//
//  TeamRoute.swift
//  StockFlow
//
//  Created by Cicek on 04.10.26.
//

enum TeamRoute: Hashable {
    case addSalesAssociate
    case salesAssociateDetail(SalesAssociateResponse)
    case editSalesAssociate(SalesAssociateResponse)

}
