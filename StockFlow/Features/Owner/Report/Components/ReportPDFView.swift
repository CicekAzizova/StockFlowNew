//
//  ReportPDFView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// PDF üçün sadə, ağ fonlu hesabat görünüşü.
struct ReportPDFView: View {

    let report: SalesReport
    let period: ReportPeriod
    /// nil = bütün məkanlar.
    let locationName: String?

    @Environment(\.locale) private var locale

    private var activeRows: [ReportBucket] {
        report.buckets.filter { $0.orders > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            metrics
            if !activeRows.isEmpty { table }
            if !report.byLocation.isEmpty { locations }
            if report.unknownCostRevenue > 0 { note }
        }
        .padding(32)
        .frame(width: 595, alignment: .leading)
        .background(Color.white)
        .foregroundStyle(Color.black)
        .environment(\.colorScheme, .light)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Report")
                .font(.system(size: 28, weight: .bold))

            HStack(spacing: 6) {
                if let locationName {
                    Text(verbatim: locationName)
                } else {
                    Text("All locations")
                }
                Text(verbatim: "·")
                Text(verbatim: periodText)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.gray)
        }
    }

    private var periodText: String {
        switch period {
        case .year:
            return String(report.from.prefix(4))
        case .week, .month:
            return "\(dayText(report.from)) – \(dayText(report.to))"
        }
    }

    // MARK: - Metrics

    private var metrics: some View {
        VStack(spacing: 8) {
            metricRow("Revenue", report.revenue.asCurrency, change(report.revenue, report.previous.revenue))
            metricRow("Profit", report.profit.asCurrency, change(report.profit, report.previous.profit))
            metricRow("Sales", "\(report.orders)", change(Double(report.orders), Double(report.previous.orders)))
            metricRow("Items sold", "\(report.itemsSold)", change(Double(report.itemsSold), Double(report.previous.itemsSold)))
        }
    }

    private func metricRow(_ title: LocalizedStringKey, _ value: String, _ change: Double?) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.gray)
            Spacer()
            if let change {
                Text(verbatim: changeText(change))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(change >= 0 ? Color.green : Color.red)
            }
            Text(verbatim: value)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 130, alignment: .trailing)
        }
        .font(.system(size: 14))
    }

    // MARK: - Table

    private var table: some View {
        VStack(spacing: 0) {
            tableRow(date: nil, revenue: nil, profit: nil, orders: nil, isHeader: true)
            Divider()
            ForEach(activeRows) { row in
                tableRow(
                    date: bucketText(row.label),
                    revenue: row.revenue.asCurrency,
                    profit: row.profit.asCurrency,
                    orders: "\(row.orders)",
                    isHeader: false
                )
            }
        }
    }

    private func tableRow(date: String?, revenue: String?, profit: String?, orders: String?, isHeader: Bool) -> some View {
        HStack {
            if isHeader {
                Text("Date").frame(maxWidth: .infinity, alignment: .leading)
                Text("Revenue").frame(width: 110, alignment: .trailing)
                Text("Profit").frame(width: 110, alignment: .trailing)
                Text("Sales").frame(width: 50, alignment: .trailing)
            } else {
                Text(verbatim: date ?? "").frame(maxWidth: .infinity, alignment: .leading)
                Text(verbatim: revenue ?? "").frame(width: 110, alignment: .trailing)
                Text(verbatim: profit ?? "").frame(width: 110, alignment: .trailing)
                Text(verbatim: orders ?? "").frame(width: 50, alignment: .trailing)
            }
        }
        .font(.system(size: 12, weight: isHeader ? .bold : .regular))
        .foregroundStyle(isHeader ? Color.gray : Color.black)
        .padding(.vertical, 5)
    }

    // MARK: - By location

    private var locations: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("By location")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.gray)

            ForEach(report.byLocation) { location in
                HStack {
                    Text(verbatim: location.name)
                    Spacer()
                    Text(verbatim: location.revenue.asCurrency)
                        .fontWeight(.bold)
                }
                .font(.system(size: 13))
            }
        }
    }

    // MARK: - Note

    private var note: some View {
        Text("\(report.unknownCostRevenue.asCurrency) of sales have no cost price, so they are not included in profit.")
            .font(.system(size: 11))
            .foregroundStyle(Color.gray)
    }

    // MARK: - Helpers

    private func change(_ current: Double, _ previous: Double) -> Double? {
        guard previous > 0 else { return nil }
        return (current - previous) / previous * 100
    }

    private func changeText(_ change: Double) -> String {
        let arrow = change >= 0 ? "▲" : "▼"
        return "\(arrow) \(Int(abs(change).rounded()))%"
    }

    private func parse(_ label: String, _ pattern: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = pattern
        return f.date(from: label)
    }

    private func dayText(_ label: String) -> String {
        guard let date = parse(label, "yyyy-MM-dd") else { return label }
        let f = DateFormatter()
        f.locale = locale
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }

    private func bucketText(_ label: String) -> String {
        if period == .year {
            guard let date = parse(label, "yyyy-MM") else { return label }
            let f = DateFormatter()
            f.locale = locale
            f.dateFormat = "LLLL"
            return f.string(from: date).capitalized
        }
        return dayText(label)
    }
}
