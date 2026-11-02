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
        case .addSalesAssociate:
            AddSalesAssociateView(
                viewModel: dependencies.makeAddSalesAssociateViewModel(),
                path: $path
            )
        case .salesAssociateDetail(let associate):
            SalesAssociateDetailView(
                viewModel: dependencies.makeSalesAssociateDetailViewModel(associate: associate), path: $path
            )
        case .editSalesAssociate(let associate):
            AddSalesAssociateView(viewModel: dependencies.makeAddSalesAssociateViewModel(associate: associate), path: $path)
        }
    }
}
