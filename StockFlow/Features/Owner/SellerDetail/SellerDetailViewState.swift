//
//  SellerDetailViewState.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

enum SellerDetailViewState {
    case idle
    case deleting
    case deleted
    case error(String)

    var isDeleting: Bool {
        if case .deleting = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
