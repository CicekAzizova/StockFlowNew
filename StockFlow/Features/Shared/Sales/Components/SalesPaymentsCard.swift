//
//  SalesPaymentsCard.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Seçilmiş dövrdə ödəniş növləri üzrə daxil olan pul (nağd, kart, köçürmə).
struct SalesPaymentsCard: View {

    let payments: [PaymentTotal]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Received by payment method")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            StatsRow(items: items)
        }
        .brandCard()
    }

    private var items: [StatItem] {
        payments.map { payment in
            StatItem(
                value: payment.amount.formatted(.number.precision(.fractionLength(0...2))),
                title: payment.paymentMethod.title
            )
        }
    }
}
