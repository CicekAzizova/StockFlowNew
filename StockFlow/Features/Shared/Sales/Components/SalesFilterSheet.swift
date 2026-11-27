//
//  SalesFilterSheet.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

/// Satıcı, məkan və ödəniş növü süzgəcləri. "Göstər" basılana qədər siyahı dəyişmir.
struct SalesFilterSheet: View {

    let sellers: [SalesSellerOption]
    let locations: [StoreLocation]
    let showsSellers: Bool
    let onApply: (SalesFilter) -> Void

    @State private var draft: SalesFilter
    @Environment(\.dismiss) private var dismiss

    init(
        filter: SalesFilter,
        sellers: [SalesSellerOption],
        locations: [StoreLocation],
        showsSellers: Bool,
        onApply: @escaping (SalesFilter) -> Void
    ) {
        _draft = State(initialValue: filter)
        self.sellers = sellers
        self.locations = locations
        self.showsSellers = showsSellers
        self.onApply = onApply
    }

    private let payments: [PaymentMethod] = [.cash, .card, .transfer, .other]

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if showsSellers, sellers.count > 1 {
                        sellerSection
                    }
                    if locations.count > 1 {
                        locationSection
                    }
                    paymentSection
                }
                .padding(16)
            }

            applyButton
        }
        .background(Color.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Başlıq

    private var header: some View {
        HStack {
            Text("Filter")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button("Reset") { draft = SalesFilter() }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandTeal)
                .disabled(draft.activeCount == 0)
                .opacity(draft.activeCount == 0 ? 0.4 : 1)
        }
        .padding(16)
    }

    // MARK: - Bölmələr

    private var sellerSection: some View {
        section(title: "Seller") {
            chip(title: Text("All"), isSelected: draft.sellerId == nil) {
                draft.sellerId = nil
            }

            ForEach(sellers) { seller in
                chip(
                    title: Text(verbatim: seller.name),
                    isSelected: draft.sellerId == seller.id
                ) {
                    draft.sellerId = seller.id
                }
            }
        }
    }

    private var locationSection: some View {
        section(title: "Location") {
            chip(title: Text("All"), isSelected: draft.locationId == nil) {
                draft.locationId = nil
            }

            ForEach(locations) { location in
                chip(
                    title: Text(verbatim: location.name),
                    isSelected: draft.locationId == location.id
                ) {
                    draft.locationId = location.id
                }
            }
        }
    }

    private var paymentSection: some View {
        section(title: "Payment") {
            chip(title: Text("All"), isSelected: draft.paymentMethod == nil) {
                draft.paymentMethod = nil
            }

            ForEach(payments, id: \.self) { method in
                chip(
                    title: Text(method.title),
                    isSelected: draft.paymentMethod == method
                ) {
                    draft.paymentMethod = method
                }
            }
        }
    }

    // MARK: - Kiçik hissələr

    private func section<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    content()
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func chip(
        title: Text,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                }
                title
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? Color.brandDark : Color.textSecondary)
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.brandGreen.opacity(0.15) : Color.surface,
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(isSelected ? Color.brandGreen : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var applyButton: some View {
        Button {
            onApply(draft)
            dismiss()
        } label: {
            Text("Show sales")
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
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
