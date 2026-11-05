//
//  SellerRequest.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

struct SellerRequest: Encodable {
    let name: String
    let surname: String
    let fin: String
    let phone: String
    let email: String
    let password:String
}
