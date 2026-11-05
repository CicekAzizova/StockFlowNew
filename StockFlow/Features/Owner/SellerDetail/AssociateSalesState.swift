//
//  AssociateSalesState.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

enum AssociateSalesState {
    case idle
    case loading
    case loaded
    case error(String)

    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
