//
//  ReceiptPDFView.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

/// Çap və paylaşma üçün qəbz görünüşü (ağ fon, dar en).
struct ReceiptPDFView: View {

    let sale: SaleResponse
    let storeName: String
    let locationName: String?

    private var receiptTitle: String {
        sale.receiptNo.map { "#\($0)" } ?? "#\(sale.id)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            Divider()
            items
            Divider()
            totals
            if let payments = sale.payments, payments.count > 1 {
                paymentLines(payments)
            }
            footer
        }
        .padding(24)
        .frame(width: 320, alignment: .leading)
        .background(Color.white)
        .foregroundStyle(Color.black)
        .environment(\.colorScheme, .light)
    }

    // MARK: - Hissələr

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: storeName)
                .font(.headline)

            if let locationName {
                Text(verbatim: locationName)
                    .font(.caption)
            }

            Text(verbatim: receiptTitle)
                .font(.subheadline.weight(.semibold))

            Text(verbatim: sale.createdAt.formatted(date: .long, time: .shortened))
                .font(.caption)
        }
    }

    private var items: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array((sale.items ?? []).enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(verbatim: item.productName)
                            .font(.caption)
                        Text(verbatim: "\(item.quantity) × \(unitPrice(item))")
                            .font(.caption2)
                    }

                    Spacer(minLength: 8)

                    Text(verbatim: item.lineTotal.asCurrency)
                        .font(.caption)
                }
            }
        }
    }

    private func unitPrice(_ item: SaleItemResponse) -> String {
        guard item.quantity > 0 else { return item.lineTotal.asCurrency }
        return (item.lineTotal / Double(item.quantity)).asCurrency
    }

    private var totals: some View {
        VStack(spacing: 4) {
            if sale.isReturned {
                row(title: Text("Total sales"), value: sale.totalPrice.asCurrency)
                row(title: Text("Refunded"), value: "−\(sale.returnedAmount.asCurrency)")
            }

            HStack {
                Text("Total")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text(verbatim: sale.netTotal.asCurrency)
                    .font(.subheadline.weight(.bold))
            }
        }
    }

    private func paymentLines(_ payments: [SalePaymentResponse]) -> some View {
        VStack(spacing: 4) {
            ForEach(payments, id: \.method) { payment in
                row(title: Text(payment.paymentMethod.title), value: payment.amount.asCurrency)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 2) {
            row(title: Text("Payment"), value: nil, trailing: Text(sale.paymentMethod.title))
            row(title: Text("Seller"), value: sale.sellerName ?? "-")
        }
        .padding(.top, 4)
    }

    private func row(title: Text, value: String?, trailing: Text? = nil) -> some View {
        HStack {
            title
            Spacer()
            if let value {
                Text(verbatim: value)
            } else if let trailing {
                trailing
            }
        }
        .font(.caption)
    }
}
