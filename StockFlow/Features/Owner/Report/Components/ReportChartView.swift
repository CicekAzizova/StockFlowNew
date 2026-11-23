//
//  ReportChartView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI
import Charts

enum ReportMetric: String, CaseIterable, Identifiable {
    case revenue, profit
    var id: String { rawValue }
}

struct ReportChartView: View {

    let buckets: [ReportBucket]
    let period: ReportPeriod
    /// İl görünüşündə seçilə bilən illər (yeni illər yuxarıda).
    var years: [Int] = []
    var selectedYear: Int? = nil
    var onSelectYear: (Int) -> Void = { _ in }

    @Environment(\.locale) private var locale
    @State private var metric: ReportMetric = .revenue
    @State private var selectedLabel: String?

    /// Ay görünüşündə eyni anda görünən sütun sayı (qalanı sürüşdürülür).
    private let visibleMonthBars = 10

    private func value(_ bucket: ReportBucket) -> Double {
        metric == .revenue ? bucket.revenue : bucket.profit
    }

    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [.brandGreen, .brandDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Seçilmiş sütun. Seçilməyibsə: ildə son satışı olan ay, qalanında sonuncu sütun.
    private var selected: ReportBucket? {
        if let bucket = buckets.first(where: { $0.label == selectedLabel }) {
            return bucket
        }
        if period == .year {
            return buckets.last { $0.orders > 0 } ?? buckets.last
        }
        return buckets.last
    }

    private var isScrollable: Bool {
        period == .month && buckets.count > visibleMonthBars
    }

    /// Başlanğıcda görünən ilk sütun: sondan 10-cu (yəni son 10 gün açılır).
    private var initialLabel: String {
        buckets[max(0, buckets.count - visibleMonthBars)].label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Metric", selection: $metric) {
                Text("Revenue").tag(ReportMetric.revenue)
                Text("Profit").tag(ReportMetric.profit)
            }
            .pickerStyle(.segmented)

            if let selected {
                HStack(spacing: 8) {
                    Text(verbatim: title(for: selected.label))
                        .foregroundStyle(.secondary)

                    if period == .year, let selectedYear {
                        yearMenu(selectedYear)
                    }

                    Spacer()

                    Text(verbatim: value(selected).asCurrency)
                        .fontWeight(.bold)
                }
                .font(.subheadline)            }

            chart
        }
        .brandCard()
        .onChange(of: period) {
            selectedLabel = nil
        }
        .onChange(of: buckets.first?.label) {
            selectedLabel = nil
        }
    }

    // MARK: - Year menu

    private func yearMenu(_ selectedYear: Int) -> some View {
        Menu {
            ForEach(years, id: \.self) { year in
                Button {
                    onSelectYear(year)
                } label: {
                    if year == selectedYear {
                        Label(String(year), systemImage: "checkmark")
                    } else {
                        Text(verbatim: String(year))
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(verbatim: String(selectedYear))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.brandTeal)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.brandTeal.opacity(0.12), in: Capsule())
        }
    }

    // MARK: - Chart

    @ViewBuilder
    private var chart: some View {
        if buckets.isEmpty {
            EmptyView()
        } else {
            Chart(buckets) { bucket in
                BarMark(
                    x: .value("Date", bucket.label),
                    y: .value("Amount", value(bucket))
                )
                .foregroundStyle(
                    bucket.label == selected?.label
                        ? AnyShapeStyle(barGradient)
                        : AnyShapeStyle(Color(.systemGray5))
                )
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: buckets.map(\.label)) { axisValue in
                    if let label = axisValue.as(String.self) {
                        AxisValueLabel {
                            Text(verbatim: axisText(for: label))
                                .font(.caption2)
                                .fixedSize()
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartScrollableAxes(isScrollable ? .horizontal : [])
            .chartXVisibleDomain(length: isScrollable ? visibleMonthBars : buckets.count)
            .chartScrollPosition(initialX: initialLabel)
            .chartXSelection(value: $selectedLabel)
            .chartGesture { proxy in
                SpatialTapGesture()
                    .onEnded { value in
                        proxy.selectXValue(at: value.location.x)
                    }
            }
            .id(period)
            .frame(height: 130)
        }
    }

    // MARK: - Helpers

    private func date(from label: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = period == .year ? "yyyy-MM" : "yyyy-MM-dd"
        return f.date(from: label)
    }

    private func format(_ label: String, _ pattern: String) -> String {
        guard let d = date(from: label) else { return label }
        let f = DateFormatter()
        f.locale = locale
        f.dateFormat = pattern
        return f.string(from: d).capitalized
    }

    private func axisText(for label: String) -> String {
        switch period {
        case .week: format(label, "EEE")
        case .month: format(label, "d")
        case .year: format(label, "MMM")
        }
    }

    /// İl görünüşündə yalnız ay adı (il yanındakı düymədə görünür).
    private func title(for label: String) -> String {
        switch period {
        case .week, .month: format(label, "d MMM, EEE")
        case .year: format(label, "LLLL")
        }
    }
}
