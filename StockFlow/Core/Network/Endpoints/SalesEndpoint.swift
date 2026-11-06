//
//  SalesEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 07.10.26.
//

import Foundation
enum SalesEndpoint: Endpoint {
    
    case summary
    case daily(days: Int)
    case recentSales(page: Int,limit: Int)
    case sellerSales(sellerId: Int, page: Int, limit: Int)
    case createSale(CreateSaleRequest)
    
    var path: String {
        switch self {
        case .summary:
            "/sales/summary"
        case .daily:
            "/sales/daily"
        case .recentSales, .createSale, .sellerSales:
            "/sales"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createSale:
            return .post
        case .summary,.daily, .recentSales, .sellerSales:
            return .get
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .createSale(let request):
            return request
        case .summary, .daily, .recentSales, .sellerSales:
            return nil
        }
    }
    var queryItems: [URLQueryItem]? {
        switch self {
        case .summary, .createSale:
            nil
        case .daily(let days):
            [URLQueryItem(name: "days", value: String(days))]
            
        case .recentSales(let page, let limit):
            [
                URLQueryItem(
                    name: "page",
                    value: String(page)
                ),
                URLQueryItem(
                    name: "limit",
                    value: String(limit)
                )
            ]
        case .sellerSales(let sellerId, let page, let limit):
            [
                URLQueryItem(name: "seller_id", value: String(sellerId)),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        }
    }
}
