//
//  HomeViewState.swift
//  StockFlow
//
//  Created by Cicek on 03.10.26.
//

enum HomeViewState {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
