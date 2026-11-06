//
//  ProductsEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import Foundation

enum ProductsEndpoint: Endpoint {
    
    case createProduct(ProductRequest)
    case getProducts(page: Int, limit: Int)
    case getLowStockProducts(page: Int, limit: Int)
    case productBySku(String)
    case editProduct(id: Int, request: ProductRequest)
    case deleteProduct(id: Int)
    case restockProduct(id: Int, request: RestockRequest)
    
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
        case .restockProduct(let id, _):
            "/products/\(id)/restock"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createProduct, .restockProduct:
            return .post
        case .getProducts, .getLowStockProducts, .productBySku:
            return .get
        case .editProduct:
            return .put
        case .deleteProduct:
            return .delete
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
        case .restockProduct(_, let request):
            return request
        case .getProducts, .getLowStockProducts, .productBySku, .deleteProduct:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getProducts(let page, let limit),
                .getLowStockProducts(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .productBySku(let sku):
            return [URLQueryItem(name: "sku", value: sku)]
        case .createProduct, .editProduct, .deleteProduct, .restockProduct:
            return nil
        }
    }
}
