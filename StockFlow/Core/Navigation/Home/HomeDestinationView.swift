//
//  HomeDestinationView.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//

import SwiftUI

struct HomeDestinationView: View {
    let route: HomeRoute
    let dependencies: AppDependencies
    @Binding var path: NavigationPath
    var canRestock = false

    var body: some View {
        switch route {
        case .lowStock:
            LowStockView(
                viewModel: dependencies.makeLowStockViewModel(),
                path: $path,
                canRestock: canRestock
            )
        case .salesHistory:
            SalesHistoryView(viewModel: dependencies.makeSalesHistoryViewModel())
        }
    }
}
