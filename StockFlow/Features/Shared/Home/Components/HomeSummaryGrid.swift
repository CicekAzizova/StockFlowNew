//
//  HomeSummaryGrid.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//
import SwiftUI

/// Panelin statistika kartları: Products, Low stock və (owner üçün) Sellers.
/// Satıcıda 2 kart olur.
struct HomeSummaryGrid: View {

    let productsCount: Int
    let lowStockCount: Int
    /// Verilərsə (owner), üçüncü kart "Sellers" olur. nil olsa göstərilmir.
    var associatesCount: Int? = nil

    var body: some View {
        HStack(spacing: 12) {
            HomeStatCard(
                icon: "cube",
                iconColor: .brandGreen,
                value: "\(productsCount)",
                title: "Products"
            )

            HomeStatCard(
                icon: "exclamationmark.triangle",
                iconColor: .warning,
                value: "\(lowStockCount)",
                valueColor: .warning,
                title: "Low stock"
            )

            if let associatesCount {
                HomeStatCard(
                    icon: "person.2",
                    iconColor: .brandCoral,
                    value: "\(associatesCount)",
                    title: "Sellers"
                )
            }
        }
    }
}

private struct HomeStatCard: View {

    let icon: String
    let iconColor: Color
    let value: String
    var valueColor: Color = .primary
    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.inter(.extraBold, size: 24))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(title)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.15), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
