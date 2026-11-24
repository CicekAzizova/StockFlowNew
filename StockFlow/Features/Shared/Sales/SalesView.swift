//
//  SalesView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

struct SalesView: View {

    @State private var viewModel: SalesViewModel
    @Binding var path: NavigationPath
    @State private var showsDateSheet = false
    var canFilterBySeller = false

    init(viewModel: SalesViewModel, path: Binding<NavigationPath>, canFilterBySeller: Bool = false) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.canFilterBySeller = canFilterBySeller
    }

    private var taskId: String {
        "\(viewModel.period)-\(viewModel.customFrom)-\(viewModel.customTo)-\(viewModel.sellerId ?? 0)"
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
        .task(id: taskId) {
            await viewModel.load()
        }
        .task {
            if canFilterBySeller {
                await viewModel.loadSellers()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            BrandScreenHeader(title: "Sales") {
                EmptyView()
            }
            
            if canFilterBySeller, viewModel.sellers.count > 1 {
                sellerMenu
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
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
    
    private var sellerMenu: some View {
        Menu {
            Button {
                viewModel.sellerId = nil
            } label: {
                Text("All sellers")
            }

            ForEach(viewModel.sellers) { seller in
                Button {
                    viewModel.sellerId = seller.id
                } label: {
                    Text(verbatim: seller.name)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "person.2")
                selectedSellerTitle
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(.white.opacity(0.15)))
        }
    }

    @ViewBuilder
    private var selectedSellerTitle: some View {
        if let id = viewModel.sellerId,
           let seller = viewModel.sellers.first(where: { $0.id == id }) {
            Text(verbatim: seller.name)
        } else {
            Text("All sellers")
        }
    }

    // MARK: - Məzmun

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 12) {

            if let payments = viewModel.totals?.byPayment, !payments.isEmpty {
                SalesPaymentsCard(payments: payments)
            }
            
            if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else if viewModel.isLoading && viewModel.sales.isEmpty {
                ProgressView()
                    .padding(.top, 40)
            } else if viewModel.sales.isEmpty {
                ContentUnavailableView(
                    "No sales",
                    systemImage: "receipt",
                    description: Text("No sales in this period")
                )
            } else {
                salesList
            }
        }
    }

    private var salesList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.groups) { group in
                SalesDayHeader(day: group.day)

                ForEach(group.sales, id: \.id) { sale in
                    Button {
                        path.append(SalesRoute.detail(sale))
                    } label: {
                        SaleRowView(sale: sale)
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
            path.append(SalesRoute.scanner)
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
