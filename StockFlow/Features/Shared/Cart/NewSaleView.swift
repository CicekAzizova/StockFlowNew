//
//  NewSaleView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Yeni satış axını: səbət → skan/axtarış → ödəniş → tamamlandı.
struct NewSaleView: View {

    let dependencies: AppDependencies

    @State private var cart = CartViewModel()
    @State private var showsScanner = false
    @State private var showsSearch = false
    @State private var showsPayment = false
    @State private var completed: CompletedSale?

    @Environment(\.dismiss) private var dismiss

    /// Tamamlanmış satış və nağd ödənişin detalları.
    struct CompletedSale: Identifiable {
        let response: CreateSaleResponse
        let received: Double?
        let change: Double?

        var id: Int { response.saleId }
    }

    var body: some View {
        CartView(
            viewModel: cart,
            onScan: { showsScanner = true },
            onSearch: { showsSearch = true },
            onCheckout: { showsPayment = true }
        )
        .fullScreenCover(isPresented: $showsScanner) {
            CartScannerSheet(viewModel: dependencies.makeCartScanViewModel(cart: cart))
        }
        .sheet(isPresented: $showsSearch) {
            CartSearchSheet(viewModel: dependencies.makeCartSearchViewModel(cart: cart))
        }
        .fullScreenCover(isPresented: $showsPayment) {
            paymentFlow
        }
    }

    
    /// Ödəniş və "tamamlandı" eyni pəncərədədir, arada səbət görünməsin.
    @ViewBuilder
    private var paymentFlow: some View {
        if let finished = completed {
            SaleCompletedView(
                response: finished.response,
                received: finished.received,
                change: finished.change,
                onNewSale: {
                    completed = nil
                    showsPayment = false
                },
                onClose: {
                    completed = nil
                    showsPayment = false
                    dismiss()
                }
            )
        } else {
            paymentView
        }
    }

    private var paymentView: some View {
        let viewModel = dependencies.makePaymentViewModel(cart: cart)

        return PaymentView(viewModel: viewModel) { response in
            let isCash = viewModel.kind == .cash
            completed = CompletedSale(
                response: response,
                received: isCash && viewModel.received > 0 ? viewModel.received : nil,
                change: isCash ? viewModel.change : nil
            )
            cart.clear()
        }
    }
}
