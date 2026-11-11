//
//  StoreEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 23.09.26.
//

import Foundation

enum StoreEndpoint: Endpoint {
    
    case createStore(StoreRequest)
    case updateCurrency(String)
    
    
    var path: String {
        switch self {
        case .createStore:
            "/auth/register"
        case .updateCurrency:
            "/stores/current"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createStore:
                .post
        case .updateCurrency:
                .patch
        }
    }
    var requiresAuthentication: Bool {
        switch self {
        case .createStore:
            false
        case .updateCurrency:
            true
        }
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .createStore(let request):
            return request
        case .updateCurrency(let currency):
            return UpdateStoreRequest(currency: currency)
        }
    }
}
