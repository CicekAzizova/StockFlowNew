//
//  SaleCompletedView.swift
//  StockFlow
//
//  Created by Cicek on 24.11.26.
//

import SwiftUI

/// Satış yarandıqdan sonrakı ekran: qəbz xülasəsi, paylaşma və yeni satış.
struct SaleCompletedView: View {

    let response: CreateSaleResponse
    /// Nağd ödənişdə müştəridən alınan və qaytarılan (varsa).
    var received: Double? = nil
    var change: Double? = nil

    let onNewSale: () -> Void
    let onClose: () -> Void

    private var sale: SaleResponse? { response.sale }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    receiptCard
                }
                .padding(16)
            }
        }
        .background(Color.background)
        .safeAreaInset(edge: .bottom) {
            buttons
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.brandGreen)
                .frame(width: 76, height: 76)
                .background(.white, in: Circle())

            Text("Sale completed")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(verbatim: subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .brandHeaderBackground()
    }

    private var subtitle: String {
        var parts: [String] = []
        if let sale {
            if let receiptNo = sale.receiptNo {
                parts.append("#\(receiptNo)")
            }
            parts.append(sale.createdAt.formatted(date: .omitted, time: .shortened))
        }
        return parts.joined(separator: " · ")
    }

    // MARK: - Qəbz

    private var receiptCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: response.totalPrice.asCurrency)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if let sale {
                    Text(sale.paymentMethod.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.brandGreen.opacity(0.12), in: Capsule())
                }
            }

            if let items = sale?.items, !items.isEmpty {
                Divider()

                VStack(spacing: 10) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        HStack {
                            HStack(spacing: 4) {
                                Text(verbatim: item.productName)
                                    .foregroundStyle(Color.textPrimary)
                                Text(verbatim: "×\(item.quantity)")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .lineLimit(1)

                            Spacer(minLength: 8)

                            Text(verbatim: item.lineTotal.asCurrency)
                                .foregroundStyle(Color.textPrimary)
                        }
                        .font(.subheadline)
                    }
                }
            }

            if let received, let change {
                Divider()

                HStack {
                    Text("Received / Change")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text(verbatim: "\(received.asCurrency) / \(change.asCurrency)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .brandCard()
    }

    // MARK: - Düymələr

    private var buttons: some View {
        VStack(spacing: 10) {
            Button(action: onNewSale) {
                Label("New sale", systemImage: "plus")
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

            Button(action: onClose) {
                Text("Done")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }
}
