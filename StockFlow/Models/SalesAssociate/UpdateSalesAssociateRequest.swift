//
//  UpdateSalesAssociateRequest.swift
//  StockFlow
//
//  Created by Cicek on 02.11.26.
//

struct UpdateSalesAssociateRequest: Encodable {
    let name: String?
    let surname: String?
    let fin: String?
    let phone: String?
    let email: String?
    let password:String?
}
