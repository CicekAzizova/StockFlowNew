//
//  SalesSummarySheet.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

/// Gün sonu çıxarışı: seçilmiş dövrdə nə satılıb, hansı üsulla nə qədər pul yığılıb.
struct SalesSummarySheet: View {

    let totals: SalesTotalsResponse
    let rangeText: String
    let sellers: [SellerTotals]
    let showsSellers: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    revenueCard
                    paymentsCard
                    if showsSellers, sellers.count > 1 {
                        sellersCard
                    }
                }
                .padding(16)
            }

            shareButton
        }
        .background(Color.background)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Başlıq

    private var header: some View {
        VStack(spacing: 2) {
            Text("End of day")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text(verbatim: rangeText)
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }

    // MARK: - Kartlar

    private var revenueCard: some View {
        VStack(spacing: 10) {
            Text("Turnover")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            Text(verbatim: totals.revenue.asCurrency)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            if totals.returned > 0 {
                VStack(spacing: 6) {
                    line(
                        title: "Total sales",
                        value: (totals.revenue + totals.returned).asCurrency,
                        color: Color.textPrimary
                    )
                    line(
                        title: "Refunded",
                        value: "−\(totals.returned.asCurrency)",
                        color: Color.brandCoral
                    )
                }
            }

            Divider()

            StatsRow(items: [
                StatItem(value: "\(totals.orders)", title: "Sales count"),
                StatItem(value: "\(totals.itemsSold)", title: "Items sold"),
                StatItem(value: totals.averageCheck.asCurrency, title: "Average check")
            ])
        }
        .brandCard()
    }
    private var paymentsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Received by payment method")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            if let payments = totals.byPayment, !payments.isEmpty {
                ForEach(payments, id: \.method) { payment in
                    paymentRow(payment)

                    if payment.method != payments.last?.method {
                        Divider()
                    }
                }
            } else {
                Text("No sales")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .brandCard()
    }

    private func paymentRow(_ payment: PaymentTotal) -> some View {
        VStack(spacing: 6) {
            Text(payment.paymentMethod.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            line(title: "Received", value: payment.received.asCurrency, color: Color.textSecondary)

            if payment.refunded > 0 {
                line(
                    title: "Refunded",
                    value: "−\(payment.refunded.asCurrency)",
                    color: Color.brandCoral
                )
            }

            Divider()

            line(
                title: "Result",
                value: payment.amount.asCurrency,
                color: payment.amount < 0 ? Color.brandCoral : Color.textPrimary,
                isBold: true
            )
        }
    }

    private func line(
        title: LocalizedStringKey,
        value: String,
        color: Color,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(isBold ? Color.textPrimary : Color.textSecondary)
            Spacer()
            Text(verbatim: value)
                .fontWeight(isBold ? .bold : .medium)
                .foregroundStyle(color)
        }
        .font(isBold ? .subheadline : .caption)
    }
    
    private var sellersCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By seller")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            ForEach(sellers, id: \.sellerId) { seller in
                HStack {
                    Text(verbatim: seller.sellerName)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(verbatim: "\(seller.orders) · \(seller.revenue.asCurrency)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                }
                .font(.subheadline)
            }
        }
        .brandCard()
    }

    // MARK: - Paylaşma

    private var shareButton: some View {
        ShareLink(item: shareText) {
            Label("Share", systemImage: "square.and.arrow.up")
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

    /// WhatsApp və ya qeydlərə göndərmək üçün sadə mətn.
    private var shareText: String {
        var lines = [
            "\(String(localized: "End of day")) · \(rangeText)",
            "\(String(localized: "Turnover")): \(totals.revenue.asCurrency)",
            "\(String(localized: "Sales count")): \(totals.orders)",
            "\(String(localized: "Items sold")): \(totals.itemsSold)"
        ]
        if totals.returned > 0 {
            lines.append("\(String(localized: "Refunded")): \(totals.returned.asCurrency)")
        }
        for payment in totals.byPayment ?? [] {
            lines.append("\(String(localized: payment.paymentMethod.titleKey)): \(payment.amount.asCurrency)")
        }
        return lines.joined(separator: "\n")
    }
    
    
}
