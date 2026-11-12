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
    case updateStore(UpdateStoreRequest)
    
    
    var path: String {
        switch self {
        case .createStore:
            "/auth/register"
        case .updateCurrency, .updateStore:
            "/stores/current"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .createStore:
                .post
        case .updateCurrency, .updateStore:
                .patch
        }
    }
    var requiresAuthentication: Bool {
        switch self {
        case .createStore:
            false
        case .updateCurrency, .updateStore:
            true
        }
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .createStore(let request):
            return request
        case .updateCurrency(let currency):
            return UpdateStoreRequest(currency: currency)
        case .updateStore(let request):
                    return request
        }
    }
}
