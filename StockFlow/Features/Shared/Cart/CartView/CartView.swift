//
//  CartView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

struct CartView: View {

    let viewModel: CartViewModel
    var onScan: () -> Void = {}
    var onSearch: () -> Void = {}
    var onCheckout: () -> Void = {}

    @State private var showsDiscountSheet = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    if viewModel.isEmpty {
                        emptyState
                    } else {
                        itemsSection
                    }

                    addButtons

                    if !viewModel.isEmpty {
                        CartTotalsCard(
                            subtotal: viewModel.subtotal,
                            totalDiscount: viewModel.totalDiscount,
                            total: viewModel.total,
                            onDiscountTap: { showsDiscountSheet = true }
                        )
                    }
                }
                .padding(16)
            }
        }
        .background(Color.background)
        .safeAreaInset(edge: .bottom) {
            checkoutButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsDiscountSheet) {
            CartDiscountSheet(
                discountedSubtotal: viewModel.discountedSubtotal,
                current: viewModel.manualDiscount,
                onApply: { viewModel.setManualDiscount($0) }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        BrandScreenHeader(title: "New sale", showsBackButton: true) {
            if !viewModel.isEmpty {
                BrandHeaderIconButton(systemImage: "trash", accessibilityLabel: "Clear") {
                    viewModel.clear()
                }
            }
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }

    // MARK: - Məhsullar

    private var itemsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Basket · \(viewModel.itemsCount) items")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Button("Clear") { viewModel.clear() }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.brandTeal)
            }

            VStack(spacing: 0) {
                ForEach(viewModel.items) { item in
                    CartItemRow(
                        item: item,
                        onIncrement: { viewModel.increment(item) },
                        onDecrement: { viewModel.decrement(item) }
                    )

                    if item.id != viewModel.items.last?.id {
                        Divider()
                    }
                }
            }
            .brandCard()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Basket is empty",
            systemImage: "cart",
            description: Text("Add products by scanning or searching")
        )
        .padding(.top, 30)
    }

    // MARK: - Skan et / Axtar

    private var addButtons: some View {
        HStack(spacing: 12) {
            addButton(title: "Scan", systemImage: "barcode.viewfinder", action: onScan)
            addButton(title: "Search", systemImage: "magnifyingglass", action: onSearch)
        }
    }

    private func addButton(
        title: LocalizedStringKey,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            Color.textSecondary.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ödənişə keç

    private var checkoutButton: some View {
        Button(action: onCheckout) {
            HStack(spacing: 6) {
                Text("Proceed to payment")
                Text(verbatim: "· \(viewModel.total.asCurrency)")
                Image(systemName: "arrow.right")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.brandDark, .brandGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
        }
        .disabled(viewModel.isEmpty)
        .opacity(viewModel.isEmpty ? 0.5 : 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }
}

#if DEBUG
#Preview {
    let cart = CartViewModel()
    cart.add(PreviewData.products[0])
    return CartView(viewModel: cart)
}
#endif
