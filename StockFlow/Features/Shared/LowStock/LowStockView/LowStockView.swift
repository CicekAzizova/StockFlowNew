//
//  LowStockView.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import SwiftUI

struct LowStockView: View {
    @State var viewModel: LowStockViewModel
    @Binding var path: NavigationPath
    
    /// Yalnız owner qalığı artıra bilər.
    var canRestock = false

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                headerBlock
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .toolbar(.hidden, for: .navigationBar)
            
        }
        
        .task {
            await viewModel.loadProductsIfNeeded()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.restockTarget != nil },
                set: { if !$0 { viewModel.restockTarget = nil } }
            )
        ) {
            if let product = viewModel.restockTarget {
                RestockSheet(
                    product: product,
                    isSaving: viewModel.isRestocking,
                    errorMessage: viewModel.restockError
                ) { quantity in
                    Task { await viewModel.restock(quantity: quantity) }
                }
            }
        }
    }
    
    // MARK: - Header

    private var headerBlock: some View {
        VStack(spacing: 0) {
            BrandScreenHeader(
                title: "Low Stock",
                subtitle: String(localized: "\(viewModel.count(for: .all)) products below minimum"),
                showsBackButton: true
            )

            filterChips
                .padding(.horizontal, 16)
                .padding(.top, 4)
        }
        .padding(.bottom, 16)
        .brandHeaderBackground()
    }

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(LowStockFilter.allCases) { filter in
                LowStockChip(
                    filter: filter,
                    count: viewModel.count(for: filter),
                    isSelected: viewModel.selectedFilter == filter
                ) {
                    viewModel.selectedFilter = filter
                }
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
            
        case .loaded:
            if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "Stock levels are healthy",
                    systemImage: "checkmark.circle",
                    description: Text("No products are running low.")
                )
            } else {
                lowStockList
            }

        case .error(let message):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.loadProducts() }
                }
            }
        }
    }

    private var lowStockList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.filteredProducts, id: \.id) { product in
                    Button {
                        path.append(ProductRoute.productDetail(product))
                    } label: {
                        LowStockProductCard(
                            product: product,
                            onRestock: canRestock ? { viewModel.startRestock(product) } : nil
                        )
                    }
                    .buttonStyle(.plain)
                    .task {
                        if product.id == viewModel.filteredProducts.last?.id {
                            await viewModel.loadMoreProducts()
                        }
                    }
                }
                if let error = viewModel.loadMoreError {
                    Text(error)
                        .font(.inter(.regular, size: 13))
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding()
        }
    }
}


/// Gradient üzərində çip: seçilmişdə ağ fon, seçilməmişdə şəffaf.
private struct LowStockChip: View {

    let filter: LowStockFilter
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(filter.title)
                Text("\(count)")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Color.brandDark : Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white : Color.white.opacity(0.18))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
