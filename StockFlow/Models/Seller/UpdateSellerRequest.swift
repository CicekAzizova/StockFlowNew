//
//  UpdateSellerRequest.swift
//  StockFlow
//
//  Created by Cicek on 02.11.26.
//
import Foundation

struct UpdateSellerRequest: Encodable {
    let name: String?
    let surname: String?
    let fin: String?
    let phone: String?
    let email: String?
    let password: String?
    var locationId: Int? = nil

    enum CodingKeys: String, CodingKey {
        case name, surname, fin, phone, email, password
        case locationId = "location_id"
    }
}
