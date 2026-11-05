//
//  ScanProductState.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

enum ScanProductState {
    case scanning
    case loading
    case found(ProductsResponse)
    case saleCompleted(total: Double)
    case notFound(String)
    case error(String)
}
