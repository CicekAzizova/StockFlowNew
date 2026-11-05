//
//  AddSellerViewState.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

enum AddSellerViewState {
    case idle
    case loading
    case success(SellerResponse)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
