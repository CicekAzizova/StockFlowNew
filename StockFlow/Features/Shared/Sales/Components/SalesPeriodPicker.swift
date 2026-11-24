//
//  SalesPeriodPicker.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Gradient üstündə Bu gün / Həftə / Ay / Tarix seçimi.
struct SalesPeriodPicker: View {

    @Binding var selection: SalesPeriod
    var onReselect: () -> Void = {}

    private let periods: [SalesPeriod] = [.today, .week, .month, .custom]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(periods, id: \.self) { period in
                let isSelected = period == selection

                Button {
                    if period == selection {
                        onReselect()
                    } else {
                        withAnimation(.snappy) {
                            selection = period
                        }
                    }
                } label: {
                    Text(title(for: period))
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.brandDark : .white.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                Capsule().fill(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(.white.opacity(0.15)))
    }

    private func title(for period: SalesPeriod) -> LocalizedStringKey {
        switch period {
        case .today: "Today"
        case .week: "Week"
        case .month: "Month"
        case .custom: "Pick date"
        }
    }
}
