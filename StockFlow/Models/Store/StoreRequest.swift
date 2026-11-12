//
//  StoreRequest.swift
//  StockFlow
//
//  Created by Cicek on 23.09.26.
//

import Foundation

struct StoreRequest: Encodable {
    let name: String
    let surname: String
    let email: String
    let password:String
    let phone: String
    
    var timezone: String = TimeZone.current.identifier

   
    
    enum CodingKeys: String, CodingKey {
        case name, email, password, phone, surname, timezone
    }
}
