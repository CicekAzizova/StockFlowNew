//
//  SalesDestinationView.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

import SwiftUI

struct SalesDestinationView: View {
    let route: SalesRoute
    let dependencies: AppDependencies
    var canReturn = false

    var body: some View {
        switch route {
        case .scanner:
            NewSaleView(dependencies: dependencies)
        case .detail(let sale):
            SaleDetailView(
                sale: sale,
                repository: dependencies.salesRepository,
                canReturn: canReturn,
                locationSwitcher: dependencies.locationSwitcher,
                productsStore: dependencies.productsStore
            )        }
    }
}
