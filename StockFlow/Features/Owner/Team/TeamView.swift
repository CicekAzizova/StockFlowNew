//
//  TeamView.swift
//  StockFlow
//
//  Created by Cicek on 04.10.26.
//

import SwiftUI

struct TeamView: View {

    @Binding var path: NavigationPath
    @State var viewModel: TeamViewModel
    @State private var isSearchPresented = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBlock

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadSellers()
        }
    }

    // MARK: - Header

    private var headerBlock: some View {
        VStack(spacing: 0) {
            BrandScreenHeader(title: "Team", showsBackButton: true) {
                HStack(spacing: 8) {
                    BrandHeaderIconButton(
                        systemImage: isSearchPresented ? "xmark" : "magnifyingglass",
                        accessibilityLabel: "Search"
                    ) {
                        toggleSearch()
                    }

                    BrandHeaderIconButton(
                        systemImage: "plus",
                        accessibilityLabel: "Add Sales Associate"
                    ) {
                        path.append(TeamRoute.addSeller)
                    }
                }
            }

            if isSearchPresented {
                BrandSearchField(
                    placeholder: "Search by name, phone or email",
                    text: $viewModel.searchText
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if viewModel.state.isLoaded {
                statsCard
            }
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }

    private var statsCard: some View {
        StatsRow(items: [
            StatItem(value: viewModel.sellerCount.formatted(), title: "Sales Associates"),
            StatItem(value: viewModel.onlineCount.formatted(), title: "Online now"),
            StatItem(value: viewModel.todayTotalSales.asCurrency, title: "Today")
        ])
        .brandCard()
        .padding(.horizontal, 16)
    }
    private func toggleSearch() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isSearchPresented.toggle()
        }
        if !isSearchPresented {
            viewModel.searchText = ""
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .loading:
            ProgressView("Loading team...")

        case .loaded:
            if viewModel.sellers.isEmpty {
                ContentUnavailableView(
                    "No Team Members",
                    systemImage: "person.2",
                    description: Text("Add your first sales associate.")
                )
            } else if viewModel.filteredSellers.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                sellersList
            }

        case .error(let message):
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }

    private var sellersList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Sales Associates")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 6)

                ForEach(viewModel.filteredSellers, id: \.id) { seller in
                    Button {
                        path.append(TeamRoute.sellerDetail(seller))
                    } label: {
                        SellerInfoCardView(associate: seller)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}
