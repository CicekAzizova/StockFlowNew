//
//  SellerDetailView.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

import SwiftUI

struct SellerDetailView: View {
    @State var viewModel: SellerDetailViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showingDeactivateConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Binding var path: NavigationPath

    private var isBusy: Bool {
        viewModel.state.isDeleting || viewModel.isChangingStatus
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBlock

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        infoCard
                        salesSection
                        SellerActionsCard(
                            isDeactivated: viewModel.associate.isDeactivated,
                            isBusy: isBusy,
                            onToggleActiveTap: toggleActive,
                            onDeleteTap: { showingDeleteConfirmation = true }
                        )
                    }
                    .padding(16)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadSalesIfNeeded()
        }
        .task {
            await viewModel.reloadAssociate()
        }
        .overlay {
            if viewModel.state.isDeleting || viewModel.isChangingStatus {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .sheet(isPresented: $showingDeleteConfirmation) {
            DeleteAssociateSheet(
                associate: viewModel.associate,
                salesCount: viewModel.salesCount,
                onConfirm: {
                    Task {
                        await viewModel.deleteSeller()
                        if case .deleted = viewModel.state { dismiss() }
                    }
                },
                onDeactivate: viewModel.associate.isDeactivated
                    ? nil
                    : { Task { await viewModel.deactivate() } }
            )
        }
        .confirmationDialog(
            isPresented: $showingDeactivateConfirmation,
            title: "Deactivate Sales Associate?",
            message: "They won't be able to sign in. Their account and sales history are kept.",
            confirmTitle: "Deactivate"
        ) {
            Task { await viewModel.deactivate() }
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
        .alert(
            "Couldn't update",
            isPresented: Binding(
                get: { viewModel.statusError != nil },
                set: { if !$0 { viewModel.statusError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.statusError ?? "")
        }
    }

    private func toggleActive() {
        if viewModel.associate.isDeactivated {
            Task { await viewModel.activate() }
        } else {
            showingDeactivateConfirmation = true
        }
    }

    // MARK: - Header

    private var headerBlock: some View {
        VStack(spacing: 0) {
            BrandScreenHeader(title: "Sales Associate", showsBackButton: true) {
                editButton
            }

            profile
                .padding(.bottom, 16)

            statsCard
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }

    private var editButton: some View {
        BrandHeaderIconButton(
            systemImage: "pencil",
            accessibilityLabel: "Edit"
        ) {
            path.append(TeamRoute.editSeller(viewModel.associate))
        }
        .disabled(isBusy)
    }

    private var profile: some View {
        HStack(spacing: 14) {
            SellerAvatar(associate: viewModel.associate, size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.associate.name) \(viewModel.associate.surname)")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text(viewModel.associate.fin)
                    .font(.inter(.regular, size: 16))
                    .foregroundStyle(.white)

                if viewModel.associate.isDeactivated {
                    Text("Deactivated")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.2), in: Capsule())
                } else if let since = viewModel.memberSince {
                    Text("Sales Associate · since \(since)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var statsCard: some View {
        var items = [
            StatItem(value: viewModel.associate.todaySales.asCurrency, title: "Today")
        ]
        if let monthSales = viewModel.associate.monthSales {
            items.append(StatItem(value: monthSales.asCurrency, title: "This month"))
        }
        items.append(StatItem(value: viewModel.salesCount.formatted(), title: "Sales"))

        return StatsRow(items: items)
            .brandCard()
            .padding(.horizontal, 16)
    }

    // MARK: - Info

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contact")
                .font(.headline)
                .foregroundStyle(.textPrimary)

            AppSectionView {
                if let phoneURL {
                    Link(destination: phoneURL) {
                        phoneRow
                    }
                    .buttonStyle(.plain)
                } else {
                    phoneRow
                }

                if let emailURL {
                    Link(destination: emailURL) {
                        emailRow
                    }
                    .buttonStyle(.plain)
                } else {
                    emailRow
                }
            }
        }
    }

    private var phoneRow: some View {
        AppRowView(icon: "phone", tint: .brandGreen, title: "Phone") {
            Text(verbatim: viewModel.associate.phone)
                .foregroundStyle(.secondary)
        }
    }

    private var emailRow: some View {
        AppRowView(icon: "envelope", tint: .brandCoral, title: "Email") {
            Text(verbatim: viewModel.associate.email)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var phoneURL: URL? {
        let allowed = Set("+0123456789")
        let digits = viewModel.associate.phone.filter { allowed.contains($0) }
        return digits.isEmpty ? nil : URL(string: "tel:\(digits)")
    }

    private var emailURL: URL? {
        let email = viewModel.associate.email.trimmingCharacters(in: .whitespaces)
        return email.isEmpty ? nil : URL(string: "mailto:\(email)")
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
}
