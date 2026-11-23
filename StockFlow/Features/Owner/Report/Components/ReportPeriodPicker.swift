//
//  ReportPeriodPicker.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Gradient üstündə Həftə / Ay / İl seçimi.
struct ReportPeriodPicker: View {

    @Binding var selection: ReportPeriod

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ReportPeriod.allCases) { period in
                let isSelected = period == selection

                Button {
                    withAnimation(.snappy) {
                        selection = period
                    }
                } label: {
                    Text(title(for: period))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.brandDark : .white.opacity(0.85))
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

    private func title(for period: ReportPeriod) -> LocalizedStringKey {
        switch period {
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }
}
