//
//  TeamDestinationView.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import SwiftUI

struct TeamDestinationView: View {
    let route: TeamRoute
    let dependencies: AppDependencies
    @Binding var path: NavigationPath

    var body: some View {
        switch route {
        case .addSeller:
            AddSellerView(
                viewModel: dependencies.makeAddSellerViewModel(),
                path: $path
            )
        case .sellerDetail(let seller):
            SellerDetailView(
                viewModel: dependencies.makeSellerDetailViewModel(seller: seller), path: $path
            )
        case .editSeller(let seller):
            AddSellerView(viewModel: dependencies.makeAddSellerViewModel(seller: seller), path: $path)
        }
    }
}
