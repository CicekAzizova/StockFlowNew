//
//  SaleDetailView.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//
import SwiftUI

struct SaleDetailView: View {
    let sale: SaleResponse

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    header
                    detailsCard
                }
                .padding()
            }
        }
        .navigationTitle("Sale Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag.fill")
                .font(.system(size: 28))
                .foregroundStyle(.brandPrimary)
                .frame(width: 56, height: 56)
                .background(.brandPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(sale.productName)
                .font(.inter(.bold, size: 20))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)

            Text(sale.totalPrice.asCurrency)
                .font(.inter(.extraBold, size: 28))
                .foregroundStyle(.primaryBlue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 16) {
            InfoRow(title: "Quantity", value: "\(sale.quantity)")
            Divider()
            InfoRow(title: "Unit price", value: sale.unitPrice.asCurrency)

            Divider()

            InfoRow(title: "Total", value: sale.totalPrice.asCurrency)

            if let seller = sale.sellerName {
                Divider()
                InfoRow(title: "Sold by", value: seller)
            }

            Divider()

            InfoRow(
                title: "Date",
                date: sale.createdAt)
            
        }
        .font(.inter(.regular, size: 15))
        .padding()
        .background(.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
