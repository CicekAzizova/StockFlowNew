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
    case rangeSales(from: String, to: String, filter: SalesFilter, page: Int, limit: Int)
    case totals(from: String, to: String, filter: SalesFilter)
    case createCartSale(CreateCartSaleRequest)
    case createReturn(saleId: Int, request: CreateReturnRequest)
    case sale(id: Int)
    
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
        case .createReturn(let saleId, _):
            "/sales/\(saleId)/returns"
        case .sale(let id):
            "/sales/\(id)"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createCartSale, .createReturn:
            return .post
        case .summary, .daily, .sellerSales, .rangeSales, .totals, .sale:
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
        case .createReturn(_, let request):
            return request
        case .summary, .daily, .sellerSales, .rangeSales, .totals, .sale:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .summary, .createCartSale, .createReturn, .sale:
            return nil
            
        case .daily(let days):
            return [URLQueryItem(name: "days", value: String(days))]
            
        case .sellerSales(let sellerId, let page, let limit):
            return [
                URLQueryItem(name: "seller_id", value: String(sellerId)),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            
        case .rangeSales(let from, let to, let filter, let page, let limit):
            return [
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ] + filter.queryItems

        case .totals(let from, let to, let filter):
            return [
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to)
            ] + filter.queryItems
        }
    }
}
