//
//  NewSaleView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Yeni satış axını: skaner/səbət → ödəniş → tamamlandı.
struct NewSaleView: View {

    private enum Step {
        case cart, scanner
    }

    let dependencies: AppDependencies
    /// Satış tamamlanıb ekran bağlananda çağırılır (tab bardan açılanda Satışlar tabına keçmək üçün).
    private let onFinished: () -> Void

    @State private var cart = CartViewModel()
    @State private var step: Step
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

    init(
        dependencies: AppDependencies,
        startsWithScanner: Bool = false,
        onFinished: @escaping () -> Void = {}
    ) {
        self.dependencies = dependencies
        self.onFinished = onFinished
        _step = State(initialValue: startsWithScanner ? .scanner : .cart)
    }

    var body: some View {
        content
            .toolbar(step == .scanner ? .hidden : .visible, for: .tabBar)
            .sheet(isPresented: $showsSearch) {
                CartSearchSheet(viewModel: dependencies.makeCartSearchViewModel(cart: cart))
            }
            .fullScreenCover(isPresented: $showsPayment) {
                paymentFlow
            }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .scanner:
            CartScannerSheet(
                viewModel: dependencies.makeCartScanViewModel(cart: cart),
                onDone: { step = .cart }
            )

        case .cart:
            CartView(
                viewModel: cart,
                onScan: { step = .scanner },
                onSearch: { showsSearch = true },
                onCheckout: { showsPayment = true }
            )
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
                    onFinished()
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
