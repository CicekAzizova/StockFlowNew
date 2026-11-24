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

    var body: some View {
        switch route {
        case .scanner:
            NewSaleView(dependencies: dependencies)
        case .history:
            SalesHistoryView(viewModel: dependencies.makeSalesHistoryViewModel())
        case .detail(let sale):
            SaleDetailView(sale: sale, locationSwitcher: dependencies.locationSwitcher)
        }
    }
}
