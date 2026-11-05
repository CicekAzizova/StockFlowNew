//
//  RecentSalesCardView.swift
//  StockFlow
//
//  Created by Cicek on 03.10.26.
//

import SwiftUI

struct RecentSalesCardView: View {
    let sale: SaleResponse

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "bag")
                .font(.system(size: 20))
                .foregroundStyle(.brandPrimary)
                .frame(width: 40, height: 40)
                .background(.brandPrimary.opacity(0.1))
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
            VStack(alignment: .leading) {
                Text(sale.productName)
                    .font(.inter(.medium, size: 16))
                    .foregroundStyle(.textPrimary)

                Text("\(sale.quantity) × \(sale.unitPrice.asCurrency)")
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
                    .minimumScaleFactor(0.7)
            }
            .lineLimit(1)
            .foregroundStyle(.textPrimary)
            .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            Text(sale.totalPrice.asCurrency)
                .font(.inter(.semiBold, size: 16))
                .foregroundStyle(.primaryBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .layoutPriority(1)

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
