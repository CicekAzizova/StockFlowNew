//
//  SalesAssociateDetailView.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

import SwiftUI

struct SalesAssociateDetailView: View {
    @State var viewModel: SalesAssociateDetailViewModel
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    infoCard
                    salesSection
                }
                .padding()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .navigationTitle("Sales Associate")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSalesIfNeeded()
        }
        .safeAreaInset(edge: .bottom) {
            deleteButton
                .padding()
                .background(Color.background)
        }
        .confirmationDialog(
            isPresented: $showingDeleteConfirmation,
            title: "Delete Sales Associate?",
            message: "This team member will be removed permanently.",
            confirmTitle: "Delete"
        ) {
            Task {
                await viewModel.deleteSalesAssociate()
                if case .deleted = viewModel.state { dismiss() }
            }
        }
        .alert(
            "Couldn't delete",
            isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { if !$0 { viewModel.state = .idle } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(initials)
                .font(.inter(.bold, size: 28))
                .foregroundStyle(.brandPrimary)
                .frame(width: 80, height: 80)
                .background(.brandPrimary.opacity(0.1))
                .clipShape(Circle())

            Text("\(viewModel.associate.name) \(viewModel.associate.surname)")
                .font(.inter(.bold, size: 22))
                .foregroundStyle(.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var infoCard: some View {
        VStack(spacing: 12) {
            InfoRow(title: "Email", value: viewModel.associate.email)
            InfoRow(title: "FIN", value: viewModel.associate.fin)
            InfoRow(title: "Phone", value: viewModel.associate.phone)
            InfoRow(title: "Today's sales", value: viewModel.associate.todaySales.asCurrency)
        }
        .padding()
        .background(.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sales

    private var salesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.salesCount > 0 ? LocalizedStringKey("Sales (\(viewModel.salesCount))") : LocalizedStringKey("Sales"))
                .font(.inter(.semiBold, size: 18))
                .foregroundStyle(.textPrimary)

            switch viewModel.salesState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()

            case .loaded:
                if viewModel.sales.isEmpty {
                    ContentUnavailableView(
                        "No sales yet",
                        systemImage: "bag",
                        description: Text("This associate hasn't made any sales.")
                    )
                } else {
                    salesList
                }

            case .error(let message):
                ContentUnavailableView {
                    Label("Couldn't load sales", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try again") {
                        Task { await viewModel.loadSales() }
                    }
                }
            }
        }
    }

    private var salesList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.sales, id: \.id) { sale in
                Button {
                    path.append(SalesRoute.detail(sale))
                } label: {
                    RecentSalesCardView(sale: sale)
                }
                .buttonStyle(.plain)
                .task {
                    if sale.id == viewModel.sales.last?.id {
                        await viewModel.loadMoreSales()
                    }
                }
            }

            if let error = viewModel.loadMoreError {
                Text(error)
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Group {
                if viewModel.state.isDeleting {
                    ProgressView().tint(.white)
                } else {
                    Text("Delete Sales Associate")
                        .font(.inter(.semiBold, size: 16))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.state.isDeleting)
    }

    private var initials: String {
        let name = viewModel.associate.name.prefix(1)
        let surname = viewModel.associate.surname.prefix(1)
        return "\(name)\(surname)".uppercased()
    }
}
