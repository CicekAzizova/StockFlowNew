//
//  UnitSegmentedControl.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// Ölçü vahidi seçimi: Ədəd / Kq / Litr / Paket.
struct UnitSegmentedControl: View {

    @Binding var selection: ProductUnit
    @Namespace private var pill

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Unit")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textSecondary)
                .padding(.leading, 4)

            HStack(spacing: 4) {
                ForEach(ProductUnit.allCases, id: \.self) { unit in
                    let isSelected = selection == unit
                    Button {
                        withAnimation(.snappy) { selection = unit }
                    } label: {
                        Text(unit.title)
                            .font(.inter(isSelected ? .bold : .regular, size: 15))
                            .foregroundStyle(isSelected ? Color.brandTeal : Color.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.surface)
                                        .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                                        .matchedGeometryEffect(id: "pill", in: pill)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
