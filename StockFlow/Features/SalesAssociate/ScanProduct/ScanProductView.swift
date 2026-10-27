//
//  ScanProductView.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//

import SwiftUI

struct ScanProductView: View {

    @State var viewModel: ScanProductViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ScanProductViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            content
        }
        .dismissKeyboardOnTap()
        .navigationTitle("Scan Product")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - State switch

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .scanning:
            scanningView

        case .loading:
            ProgressView("Looking up product...")

        case .found(let product):
            productView(product)

        case .saleCompleted(let total):
            ContentUnavailableView {
                Label("Sale completed", systemImage: "checkmark.circle.fill")
            } description: {
                Text("Total: \(total.asCurrency)")
            } actions: {
                Button("Scan another") {
                    viewModel.rescan()
                }
                .buttonStyle(.borderedProminent)

                Button("Done") {
                    dismiss()
                }
            }

        case .notFound(let code):
            ContentUnavailableView {
                Label("Product not found", systemImage: "questionmark.circle")
            } description: {
                Text("No product with code \"\(code)\".")
            } actions: {
                Button("Try again") {
                    viewModel.rescan()
                }
                .buttonStyle(.borderedProminent)
            }

        case .error(let message):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    viewModel.rescan()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Scanning

    private var scanningView: some View {
        BarcodeInputView { code in
            Task { await viewModel.handleScanned(code: code) }
        }
    }

    // MARK: - Product & sale

    private func productView(_ product: ProductsResponse) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                SummaryCardView(product: product)

                VStack(spacing: 16) {
                    InfoRow(title: "In stock", value: "\(product.quantity)")
                    
                    if product.hasDiscount {
                        InfoRow(
                            title: "Discount",
                            value: product.discount.formatted(.number.precision(.fractionLength(0))) + "%"
                        )
                    }
                    
                    InfoRow(title: "Unit price", value: product.discountedPrice.asCurrency)

                    HStack {
                        Text("Quantity").foregroundStyle(.textSecondary)
                        Spacer()
                        QuantityStepper(
                            value: viewModel.quantity,
                            canDecrement: viewModel.canDecrement,
                            canIncrement: viewModel.canIncrement,
                            onDecrement: viewModel.decrement,
                            onIncrement: viewModel.increment
                        )
                    }

                    Divider()

                    HStack {
                        Text("Total").font(.inter(.bold, size: 16))
                        Spacer()
                        Text(viewModel.totalPrice.asCurrency)
                            .font(.inter(.extraBold, size: 20))
                    }
                }
                .font(.inter(.regular, size: 15))
                .padding()
                .background(.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let error = viewModel.submitError {
                    Text(error)
                        .font(.inter(.regular, size: 13))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await viewModel.completeSale() }
                } label: {
                    Group {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text(product.quantity == 0 ? "Out of stock" : "Complete Sale")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSubmitting || product.quantity == 0)

                Button("Scan another") { viewModel.rescan() }
                    .disabled(viewModel.isSubmitting)
            }
            .padding()
        }
    }

}
