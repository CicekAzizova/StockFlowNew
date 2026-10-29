//
//  UserRole.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import SwiftUI

enum UserRole: String, Decodable {
    case owner = "OWNER"
    case salesAssociate = "SALES_ASSOCIATE"
    
    var displayName: LocalizedStringKey {
        switch self {
        case .owner: "Owner"
        case .salesAssociate: "Sales Associate"
        }
    }
}
