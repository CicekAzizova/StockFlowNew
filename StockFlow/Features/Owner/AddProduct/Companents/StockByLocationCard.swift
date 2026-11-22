//
//  StockByLocationCard.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// "Başlanğıc qalıq": hər məkan üçün say, "Hamısına eyni" və cəmi.
struct StockByLocationCard: View {

    @Bindable var viewModel: AddProductViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if viewModel.product == nil {
                    Text("Starting stock")
                } else {
                    Text("Stock by location")
                }
                Spacer()
                if viewModel.product == nil, viewModel.locations.count > 1 {
                    Button("Same for all") {
                        viewModel.applySameStockForAll()
                    }
                    .font(.inter(.bold, size: 13))
                    .foregroundStyle(Color.brandTeal)
                }
            }
            .font(.inter(.regular, size: 13))
            .foregroundStyle(.textSecondary)
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(viewModel.locations) { location in
                    row(location)
                    if location.id != viewModel.locations.last?.id {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack {
                Text("Total stock")
                    .foregroundStyle(.textSecondary)
                Spacer()
                Text("\(viewModel.totalStock)")
                    .font(.inter(.bold, size: 16))
                    .foregroundStyle(.textPrimary)
            }
            .font(.inter(.regular, size: 14))
            .padding(.horizontal, 4)
        }
    }

    private func row(_ location: StoreLocation) -> some View {
        HStack(spacing: 12) {
            Image(systemName: location.kind == .warehouse ? "building.2" : "storefront")
                .font(.system(size: 18))
                .foregroundStyle(location.kind == .warehouse ? Color.purple : Color.brandTeal)
                .frame(width: 40, height: 40)
                .background(
                    (location.kind == .warehouse ? Color.purple : Color.brandTeal).opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: location.name)
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                Text(subtitle(for: location))
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
            }

            Spacer(minLength: 8)

            StockStepper(
                value: Binding(
                    get: { viewModel.stockByLocation[location.id] ?? 0 },
                    set: { viewModel.stockByLocation[location.id] = $0 }
                )
            )
        }
        .padding(12)
    }

    private func subtitle(for location: StoreLocation) -> LocalizedStringKey {
        if location.isMain { return "Main store" }
        return location.kind == .warehouse ? "Warehouse" : "Store"
    }
}
