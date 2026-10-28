//
//  ProductFilterPicker.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import SwiftUI

struct ProductFilterPicker: View {
    
    @Binding var selectedFilter: ProductStockFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(ProductStockFilter.allCases,id: \.self){ filter in
                    filterButton(for: filter)
                }
            }
            .padding(.vertical,16)
        }
    }
    
    private func filterButton(for filter: ProductStockFilter) -> some View {
        let isSelected = selectedFilter == filter
        return Button{
            selectedFilter = filter
        }label: {
            Text(filter.displayName)
                .font(.inter(.regular, size: 12))
                .foregroundStyle(isSelected ? .white : .textSecondary)
                .padding(.horizontal,16)
                .padding(.vertical,8)
                .background(isSelected ? .brandPrimary.opacity(0.8) : .border)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.brandPrimary : .border)
                    
                }
                .buttonStyle(.plain)
        }
                .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
