//
//  ProductDetailTabPicker.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Ümumi / Qalıq / Tarixçə seçimi.
struct ProductDetailTabPicker: View {

    @Binding var selection: ProductDetailTab
    @Namespace private var pill

    private func title(for tab: ProductDetailTab) -> LocalizedStringKey {
        switch tab {
        case .overview: "Overview"
        case .stock: "Stock"
        case .history: "History"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProductDetailTab.allCases, id: \.self) { tab in
                let isSelected = selection == tab
                Button {
                    withAnimation(.snappy) { selection = tab }
                } label: {
                    Text(title(for: tab))
                        .font(.inter(isSelected ? .bold : .regular, size: 15))
                        .foregroundStyle(isSelected ? Color.white : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.brandTeal)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
