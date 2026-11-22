//
//  ProductsEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import Foundation

enum ProductsEndpoint: Endpoint {
    
    case createProduct(ProductRequest)
    case getProducts(page: Int, limit: Int, query: String?, stock: String?)
    case getLowStockProducts(page: Int, limit: Int)
    case productBySku(String)
    case editProduct(id: Int, request: ProductRequest)
    case deleteProduct(id: Int)
    case restockProduct(id: Int, request: RestockRequest, locationId: Int?)
    case productStats
    case productHistory(id: Int, page: Int, limit: Int)
    case setForSale(id: Int, request: ForSaleRequest)
    case setStock(id: Int, request: SetStockRequest, locationId: Int)
    
    var path: String {
        switch self {
        case .createProduct:
            "/products"
        case .getProducts:
            "/products"
        case .productBySku:
             "/products/by-sku"
        case .editProduct(let id,_):
            "/products/\(id)"
        case .deleteProduct(let id):
            "/products/\(id)"
        case .getLowStockProducts:
            "/products/low-stock"
        case .restockProduct(let id, _, _):
            "/products/\(id)/restock"
        case .productStats:
            "/products/stats"
        case .productHistory(let id, _, _):
            "/products/\(id)/history"
        case .setForSale(let id, _):
            "/products/\(id)/for-sale"
        case .setStock(let id, _, _):
            "/products/\(id)/stock"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createProduct, .restockProduct:
            return .post
        case .getProducts, .getLowStockProducts, .productBySku, .productStats, .productHistory:
            return .get
        case .editProduct:
            return .put
        case .deleteProduct:
            return .delete
        case .setForSale, .setStock:
            return .patch
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .createProduct(let request):
            return request
        case .editProduct(_, let request):
            return request
        case .restockProduct(_, let request, _):
            return request
        case .setForSale(_, let request):
            return request
        case .getProducts, .getLowStockProducts, .productBySku, .deleteProduct, .productStats, .productHistory:
            return nil
        case .setStock(_, let request, _):
            return request
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getProducts(let page, let limit, let query, let stock):
            var items = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            if let query, !query.isEmpty {
                items.append(URLQueryItem(name: "q", value: query))
            }
            if let stock {
                items.append(URLQueryItem(name: "stock", value: stock))
            }
            return items
            
        case .getLowStockProducts(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .productBySku(let sku):
            return [URLQueryItem(name: "sku", value: sku)]
        case .productHistory(_, let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .createProduct, .editProduct, .deleteProduct, .restockProduct, .productStats, .setForSale, .setStock:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var headers = [
            HttpHeader.accept: Accept.json,
            HttpHeader.contentType: ContentType.json
        ]
        if case .restockProduct(_, _, let locationId?) = self {
            headers[HttpHeader.locationId] = String(locationId)
        }
        
        if case .setStock(_, _, let locationId) = self {
            headers[HttpHeader.locationId] = String(locationId)
        }
        return headers
    }
}
