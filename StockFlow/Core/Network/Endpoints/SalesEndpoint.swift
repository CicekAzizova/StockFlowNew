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
    case sellerSales(sellerId: Int, page: Int, limit: Int)
    case rangeSales(from: String, to: String, sellerId: Int?, page: Int, limit: Int)
    case totals(from: String, to: String, sellerId: Int?)
    case createCartSale(CreateCartSaleRequest)
    
    var path: String {
        switch self {
        case .summary:
            "/sales/summary"
        case .daily:
            "/sales/daily"
        case .totals:
            "/sales/totals"
        case .sellerSales, .rangeSales, .createCartSale:
            "/sales"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createCartSale:
            return .post
        case .summary, .daily, .sellerSales, .rangeSales, .totals:
            return .get
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .createCartSale(let request):
            return request
        case .summary, .daily, .sellerSales, .rangeSales, .totals:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .summary, .createCartSale:
            return nil
            
        case .daily(let days):
            return [URLQueryItem(name: "days", value: String(days))]
            
        case .sellerSales(let sellerId, let page, let limit):
            return [
                URLQueryItem(name: "seller_id", value: String(sellerId)),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            
        case .rangeSales(let from, let to, let sellerId, let page, let limit):
            var items = [
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            if let sellerId {
                items.append(URLQueryItem(name: "seller_id", value: String(sellerId)))
            }
            return items
            
        case .totals(let from, let to, let sellerId):
            var items = [
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to)
            ]
            if let sellerId {
                items.append(URLQueryItem(name: "seller_id", value: String(sellerId)))
            }
            return items
        }
    }
}
