//
//  ProductDestinationView.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//

import SwiftUI

struct ProductDestinationView: View {
    let route: ProductRoute
    let dependencies: AppDependencies
    @Binding var path: NavigationPath
    var canManageProducts: Bool = false

    var body: some View {
        switch route {
        case .productDetail(let product):
            ProductDetailView(
                viewModel: dependencies.makeProductDetailViewModel(product: product),
                path: $path,
                canManageProducts: canManageProducts,
                dependencies: canManageProducts ? dependencies : nil
            )
        case .addProductWithBarcode(let barcode) where canManageProducts:
            AddProductView(
                viewModel: dependencies.makeAddProductViewModel(barcode: barcode),
                path: $path
            )
        case .addProduct where canManageProducts:
            AddProductView(
                viewModel: dependencies.makeAddProductViewModel(),
                path: $path
            )
        case .editProduct(let product) where canManageProducts:
            AddProductView(
                viewModel: dependencies.makeAddProductViewModel(product: product),
                path: $path
            )
        default:
            EmptyView()
        }
    }
}
