//
//  WeeklySalesChartView.swift
//  StockFlow
//
//  Created by Cicek on 06.11.26.
//

import SwiftUI

/// Son 7 gün üçün sütunlu qrafik. Sütuna toxunanda həmin günün detalı görünür.
struct WeeklySalesChartView: View {

    let days: [DailySales]

    @State private var selectedId: String?

    private let chartHeight: CGFloat = 50

    private var weekTotal: Double {
        days.reduce(0) { $0 + $1.total }
    }

    private var maxTotal: Double {
        max(days.map(\.total).max() ?? 0, 1)
    }

    /// Seçilməyibsə, sonuncu gün (bu gün) göstərilir.
    private var selected: DailySales? {
        days.first { $0.id == selectedId } ?? days.last
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            bars
            if let selected {
                detail(for: selected)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandCard()
    }

    private var header: some View {
        HStack {
            Text("Last 7 days")
                .font(.headline)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Weekly")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Self.money(weekTotal)) AZN")
                    .font(.subheadline.weight(.semibold))
            }
        }
    }

    private var bars: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(days) { day in
                let isSelected = day.id == selected?.id

                Button {
                    selectedId = day.id
                } label: {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? Color.brandPrimary : Color.brandPrimary.opacity(0.3))
                            .frame(height: max(4, chartHeight * day.total / maxTotal))
                            .frame(height: chartHeight, alignment: .bottom)

                        Text(Self.shortWeekday(day.date))
                            .font(.caption2)
                            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func detail(for day: DailySales) -> some View {
        Text("\(Self.fullWeekday(day.date)) · \(Self.money(day.total)) AZN · \(day.orders) sales")
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Helpers

    private static func money(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }

    private static let parser: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func weekday(_ date: String, format: String) -> String {
        guard let d = parser.date(from: date) else { return date }
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = format
        return f.string(from: d).capitalized
    }

    private static func shortWeekday(_ date: String) -> String {
        weekday(date, format: "EEE")
    }

    private static func fullWeekday(_ date: String) -> String {
        weekday(date, format: "EEEE")
    }
}

#if DEBUG
#Preview {
    WeeklySalesChartView(days: [
        DailySales(date: "2026-10-30", total: 320, orders: 5),
        DailySales(date: "2026-10-31", total: 540, orders: 8),
        DailySales(date: "2026-11-01", total: 210, orders: 3),
        DailySales(date: "2026-11-02", total: 760, orders: 11),
        DailySales(date: "2026-11-03", total: 430, orders: 6),
        DailySales(date: "2026-11-04", total: 980, orders: 12),
        DailySales(date: "2026-11-05", total: 1125, orders: 14)
    ])
    .padding()
}
#endif
