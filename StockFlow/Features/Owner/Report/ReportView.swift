//
//  ReportView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

struct ReportView: View {

    @State private var viewModel: ReportViewModel
    @Environment(\.locale) private var locale
    @State private var pdfURL: URL?
    let locationSwitcher: LocationSwitcher

    private var locations: [StoreLocation] {
        locationSwitcher.locations
    }

    init(repository: ReportRepository, locationSwitcher: LocationSwitcher) {
        _viewModel = State(initialValue: ReportViewModel(repository: repository))
        self.locationSwitcher = locationSwitcher
    }

    private var taskId: String {
        "\(viewModel.period.rawValue)-\(viewModel.locationId ?? 0)-\(viewModel.year)"
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                content
                    .padding(16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if locationSwitcher.locations.isEmpty {
                await locationSwitcher.load()
            }
        }
        .task(id: taskId) {
            await viewModel.load()
        }
        .onChange(of: viewModel.isLoading) {
            pdfURL = viewModel.isLoading ? nil : makePDF()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            BrandScreenHeader(title: "Report", showsBackButton: true) {
                shareButton
            }

            if locations.count > 1 {
                ReportLocationMenu(locations: locations, selectedId: $viewModel.locationId)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
            }

            ReportPeriodPicker(selection: $viewModel.period)
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }
    
    // MARK: - PDF

    @ViewBuilder
    private var shareButton: some View {
        if let pdfURL {
            ShareLink(item: pdfURL) {
                BrandHeaderIcon(systemImage: "square.and.arrow.up")
            }
            .accessibilityLabel("Share")
        }
    }

    private func makePDF() -> URL? {
        guard let report = viewModel.report else { return nil }
        return ReportPDFExporter.makePDF(
            report: report,
            period: ReportPeriod(rawValue: report.period) ?? viewModel.period,
            locationName: locations.first { $0.id == viewModel.locationId }?.name,
            locale: locale
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let report = viewModel.report {
            reportContent(report)
        } else if viewModel.isLoading {
            ProgressView().padding(.top, 40)
        } else if let message = viewModel.errorMessage {
            Text(verbatim: message)
                .foregroundStyle(.secondary)
        }
    }

    private func reportContent(_ report: SalesReport) -> some View {
        VStack(spacing: 16) {
            chart(report)
            metricsGrid(report)

            if report.byLocation.count > 1 {
                ReportLocationsCard(locations: report.byLocation)
            }

            if report.unknownCostRevenue > 0 {
                ReportUnknownCostNote(amount: report.unknownCostRevenue)
            }
        }
    }

    private func chart(_ report: SalesReport) -> some View {
        ReportChartView(
            buckets: report.buckets,
            period: viewModel.period,
            years: viewModel.availableYears,
            selectedYear: viewModel.year,
            onSelectYear: { viewModel.year = $0 }
        )
    }

    private func metricsGrid(_ report: SalesReport) -> some View {
        let revenueChange = viewModel.change(current: report.revenue, previous: report.previous.revenue)
        let profitChange = viewModel.change(current: report.profit, previous: report.previous.profit)
        let ordersChange = viewModel.change(
            current: Double(report.orders),
            previous: Double(report.previous.orders)
        )
        let itemsChange = viewModel.change(
            current: Double(report.itemsSold),
            previous: Double(report.previous.itemsSold)
        )
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

        return LazyVGrid(columns: columns, spacing: 12) {
            ReportMetricCard(title: "Revenue", value: report.revenue.asCurrency, change: revenueChange)
            ReportMetricCard(title: "Profit", value: report.profit.asCurrency, change: profitChange, tint: .brandGreen)
            ReportMetricCard(title: "Sales", value: "\(report.orders)", change: ordersChange)
            ReportMetricCard(title: "Items sold", value: "\(report.itemsSold)", change: itemsChange)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReportView(
            repository: PreviewReportRepository(),
            locationSwitcher: LocationSwitcher(
                locationRepository: PreviewLocationRepository(),
                productsStore: ProductsStore(productRepository: PreviewProductRepository()),
                salesStore: SalesStore(salesRepository: PreviewSalesRepository())
            )
        )
    }
}
#endif
