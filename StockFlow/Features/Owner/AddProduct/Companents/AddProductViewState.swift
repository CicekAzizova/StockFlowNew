//
//  AddProductViewState.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//
import Foundation

enum AddProductViewState {
    case idle
    case loading
    case success(ProductsResponse)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
