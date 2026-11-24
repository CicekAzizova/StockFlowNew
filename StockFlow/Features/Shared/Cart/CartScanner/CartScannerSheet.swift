//
//  CartScannerSheet.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Səbət üçün skaner: açıq qalır, hər skan məhsulu səbətə atır.
struct CartScannerSheet: View {

    @State var viewModel: CartScanViewModel
    let onDone: () -> Void

    init(viewModel: CartScanViewModel, onDone: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onDone = onDone
    }

    var body: some View {
        ZStack(alignment: .top) {
            BarcodeInputView { code in
                Task { await viewModel.handleScanned(code: code) }
            }

            VStack(spacing: 10) {
                topBar
                banner
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .task(id: viewModel.feedbackId) {
            guard viewModel.feedback != nil else { return }
            try? await Task.sleep(for: .seconds(2.5))
            viewModel.clearFeedback()
        }
    }

    // MARK: - Üst panel

    private var topBar: some View {
        HStack {
            Text("Basket · \(viewModel.cart.itemsCount) items")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button("Done") { onDone() }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandTeal)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Mesaj

    @ViewBuilder
    private var banner: some View {
        if let feedback = viewModel.feedback {
            if case .added(let product, let quantity) = feedback {
                addedCard(product: product, quantity: quantity)
            } else {
                messageCapsule(feedback)
            }
        }
    }

    /// Əlavə olunan məhsul: şəkil, ad, barkod və səbətdəki say.
    private func addedCard(product: ProductsResponse, quantity: Int) -> some View {
        HStack(spacing: 12) {
            RemoteImageView(
                imageUrl: product.imageUrls?.first,
                width: 48,
                height: 48,
                cornerRadius: 12
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Label {
                    Text(verbatim: product.sku)
                } icon: {
                    Image(systemName: "barcode")
                }
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 8)

            Text(verbatim: "×\(quantity)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.brandGreen, in: Capsule())
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func messageCapsule(_ feedback: CartScanViewModel.Feedback) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
            message(for: feedback)
                .lineLimit(2)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color.brandCoral)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    @ViewBuilder
    private func message(for feedback: CartScanViewModel.Feedback) -> some View {
        switch feedback {
        case .added:
            EmptyView()
        case .limitReached(let name):
            Text("Not enough stock: \(name)")
        case .outOfStock(let name):
            Text("Out of stock: \(name)")
        case .notForSale(let name):
            Text("Not for sale: \(name)")
        case .notFound(let code):
            Text("Product not found: \(code)")
        case .error(let message):
            Text(verbatim: message)
        }
    }
}
