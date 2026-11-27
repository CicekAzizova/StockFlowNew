//
//  SalesView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

struct SalesView: View {

    let dependencies: AppDependencies

    @State private var viewModel: SalesViewModel
    @Binding var path: NavigationPath
    @State private var showsDateSheet = false
    @State private var showsFilter = false
    @State private var showsNewSale = false
    @State private var showsSummary = false
    var canFilterBySeller = false

    init(
        viewModel: SalesViewModel,
        path: Binding<NavigationPath>,
        dependencies: AppDependencies,
        canFilterBySeller: Bool = false
    ) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.dependencies = dependencies
        self.canFilterBySeller = canFilterBySeller
    }

    private var taskId: String {
        let filter = viewModel.filter
        return """
        \(viewModel.period)-\(viewModel.customFrom)-\(viewModel.customTo)\
        -\(filter.sellerId ?? 0)-\(filter.locationId ?? 0)-\(filter.paymentMethod?.rawValue ?? "")
        """
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            SalesTotalsCard(totals: viewModel.totals)
                .padding(.horizontal, 16)
                .padding(.top, -44) // gradientin üstünə çıxır
                .zIndex(1)

            ScrollView {
                content
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 70) // üzən düymənin altında yer
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(Color.background)
        .overlay(alignment: .bottomTrailing) {
            newSaleButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.period) {
            if viewModel.period == .custom {
                showsDateSheet = true
            }
        }
        .sheet(isPresented: $showsDateSheet) {
            SalesDateRangeSheet(from: viewModel.customFrom, to: viewModel.customTo) { from, to in
                viewModel.customFrom = from
                viewModel.customTo = to
            }
        }
        .fullScreenCover(isPresented: $showsNewSale) {
            NewSaleView(dependencies: dependencies)
        }
        .task(id: taskId) {
            await viewModel.load()
        }
        //NotificationCenter -den xeber gelende ise dusur
        .onReceive(NotificationCenter.default.publisher(for: .saleChanged)) { _ in
            Task { await viewModel.load() }
        }
        .task {
            await viewModel.loadFilterData()
        }
        .sheet(isPresented: $showsFilter) {
            SalesFilterSheet(
                filter: viewModel.filter,
                sellers: viewModel.sellers,
                locations: viewModel.locations,
                showsSellers: canFilterBySeller
            ) { newFilter in
                viewModel.filter = newFilter
            }
        }
        .sheet(isPresented: $showsSummary) {
            if let totals = viewModel.totals {
                SalesSummarySheet(
                    totals: totals,
                    rangeText: viewModel.rangeText,
                    sellers: totals.bySeller,
                    showsSellers: canFilterBySeller
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            BrandScreenHeader(title: "Sales") {
                HStack(spacing: 8) {
                    summaryButton
                    filterButton
                }
            }

            SalesPeriodPicker(selection: $viewModel.period) {
                if viewModel.period == .custom {
                    showsDateSheet = true
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 58)
        .brandHeaderBackground()
    }
    
    private var summaryButton: some View {
        Button {
            showsSummary = true
        } label: {
            BrandHeaderIcon(systemImage: "doc.text")
        }
        .disabled(viewModel.totals == nil)
        .accessibilityLabel("End of day")
    }
    
    private var filterButton: some View {
        Button {
            showsFilter = true
        } label: {
            BrandHeaderIcon(systemImage: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if viewModel.filter.activeCount > 0 {
                        Text(verbatim: "\(viewModel.filter.activeCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.brandDark)
                            .frame(width: 16, height: 16)
                            .background(.white, in: Circle())
                            .offset(x: 4, y: -4)
                    }
                }
        }
        .accessibilityLabel("Filter")
    }

    // MARK: - Məzmun

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 12) {

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .padding(.top, 40)

            case .loaded(let groups):
                salesList(groups)

            case .empty:
                ContentUnavailableView(
                    "No sales",
                    systemImage: "receipt",
                    description: Text("No sales in this period")
                )

            case .error(let message):
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
    }
    private func salesList(_ groups: [SalesDayGroup]) -> some View {
        LazyVStack(spacing: 10) {
            ForEach(groups) { group in
                SalesDayHeader(day: group.day)

                ForEach(group.sales, id: \.id) { sale in
                    Button {
                        path.append(SalesRoute.detail(sale))
                    } label: {
                        SaleRowView(sale: sale, showsLocation: viewModel.locations.count > 1)
                    }
                    .buttonStyle(.plain)
                    .task {
                        if sale.id == viewModel.sales.last?.id {
                            await viewModel.loadMore()
                        }
                    }
                    
                }
            }

            if viewModel.isLoadingMore {
                ProgressView()
            }
        }
    }

    // MARK: - Yeni satış

    private var newSaleButton: some View {
        Button {
            showsNewSale = true
        } label: {
            Label("New sale", systemImage: "plus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.brandDark, .brandGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .padding(16)
    }
}
