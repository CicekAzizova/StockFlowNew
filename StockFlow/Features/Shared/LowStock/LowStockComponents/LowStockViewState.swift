//
//  LowStockViewState.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

enum LowStockViewState {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
