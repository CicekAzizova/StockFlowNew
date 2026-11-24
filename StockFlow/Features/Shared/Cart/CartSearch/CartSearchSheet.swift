//
//  CartSearchSheet.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Məhsulu adı ilə tapıb səbətə atmaq. Pəncərə açıq qalır, bir neçə məhsul əlavə etmək olar.
struct CartSearchSheet: View {

    @State var viewModel: CartSearchViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CartSearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            searchField
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            content
        }
        .background(Color.background)
        .task(id: viewModel.query) {
            await viewModel.search()
        }
    }

    // MARK: - Üst hissə

    private var topBar: some View {
        HStack {
            Text("Search products")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button("Done") { dismiss() }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandTeal)
        }
        .padding(16)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)

            TextField("Name or barcode", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Məzmun

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxHeight: .infinity)

        case .loaded(let products):
            list(products)

        case .empty:
            ContentUnavailableView.search(text: viewModel.query)

        case .error(let message):
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }

    private func list(_ products: [ProductsResponse]) -> some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(products, id: \.id) { product in
                    row(product)
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func row(_ product: ProductsResponse) -> some View {
        let inCart = viewModel.quantityInCart(product)
        let isAvailable = product.isForSale && product.quantity > 0
        let canAdd = isAvailable && inCart < product.quantity

        return Button {
            viewModel.add(product)
        } label: {
            HStack(spacing: 12) {
                RemoteImageView(
                    imageUrl: product.imageUrls?.first,
                    width: 46,
                    height: 46,
                    cornerRadius: 12
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(verbatim: product.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(verbatim: "\(product.sku) · \(product.discountedPrice.asCurrency)")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)

                    stockLabel(product, isAvailable: isAvailable)
                }

                Spacer(minLength: 8)

                trailing(inCart: inCart, canAdd: canAdd)
            }
            .brandCard()
        }
        .buttonStyle(.plain)
        .disabled(!canAdd)
        .opacity(isAvailable ? 1 : 0.5)
    }

    @ViewBuilder
    private func stockLabel(_ product: ProductsResponse, isAvailable: Bool) -> some View {
        if !product.isForSale {
            Text("Not for sale")
                .font(.caption2)
                .foregroundStyle(Color.brandCoral)
        } else if product.quantity == 0 {
            Text("Out of stock")
                .font(.caption2)
                .foregroundStyle(Color.brandCoral)
        } else {
            Text("In stock: \(product.quantity)")
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
        }
    }

    @ViewBuilder
    private func trailing(inCart: Int, canAdd: Bool) -> some View {
        if inCart > 0 {
            Text(verbatim: "×\(inCart)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.brandGreen, in: Capsule())
        } else if canAdd {
            Image(systemName: "plus")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 32, height: 32)
                .background(Color.brandTeal.opacity(0.12), in: Circle())
        }
    }
}
