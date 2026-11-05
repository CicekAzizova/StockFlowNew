//
//  SellerSalesView.swift
//  StockFlow
//
//  Created by Cicek on 06.10.26.
//

import SwiftUI

struct SellerSalesView: View {
    
    @State var viewModel: SellerSalesViewModel
    
    @Binding var path: NavigationPath
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            content
        }
        .task {
            await viewModel.loadSales()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            salesView
        case .error(let message):
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
    
    private var salesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Sales")
                    .font(.inter(.bold, size: 24))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Sales")
                        .font(.inter(.regular, size: 14))
                        .foregroundStyle(.textSecondary)
                    
                    Text(viewModel.todaySales.asCurrency)
                        .font(.inter(.extraBold, size: 28))
                    
                    Text("\(viewModel.todayOrders) orders")
                        .font(.inter(.regular, size: 13))
                        .foregroundStyle(.textSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.border)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                AppButtonView(
                    title: "Scan Product",
                    background: .brandPrimary) {
                        path.append(SalesRoute.scanner)
                    }
                
                
                RecentSalesSection(
                    sales: viewModel.latestSales,
                    onSeeAll: { path.append(SalesRoute.history) }, path: $path
                )
            }
            .padding()
        }
    }
}
