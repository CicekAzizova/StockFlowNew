//
//  StoreInfoView.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

struct StoreInfoView: View {

    let user: User
    @State var viewModel: LocationsViewModel

    @State private var isAddPresented = false
    @State private var locationToDelete: StoreLocation?

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    locationsSection
                }
                .padding(16)
            }
        }
        .navigationTitle("Store information")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .sheet(isPresented: $isAddPresented) {
            AddLocationSheet(
                locationRepository: viewModel.repository,
                onAdded: { await viewModel.reloadAfterChange() }
            )
        }
        .confirmationDialog(
            "Delete this location?",
            isPresented: Binding(
                get: { locationToDelete != nil },
                set: { if !$0 { locationToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: locationToDelete
        ) { location in
            Button("Delete", role: .destructive) {
                Task { await viewModel.delete(location) }
            }
        }
    }

    // MARK: - Locations

    private var locationsSection: some View {
        AppSectionView("Locations") {
            ForEach(viewModel.locations) { location in
                locationRow(location)
            }

            Button {
                isAddPresented = true
            } label: {
                AppRowView(icon: "plus", tint: .brandTeal, title: "Add location") {
                    AppRowDisclosure()
                }
            }
            .buttonStyle(.plain)

            if let message = viewModel.errorMessage {
                Text(verbatim: message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
    }

    private func locationRow(_ location: StoreLocation) -> some View {
        AppRowView(icon: location.kind.icon, tint: location.kind.tint, title: LocalizedStringKey(location.name)) {
            HStack(spacing: 8) {
                if location.isMain {
                    Text("Main")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.brandTeal)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.brandTeal.opacity(0.12), in: Capsule())
                }

                if !location.isMain {
                    Menu {
                        if location.kind == .store {
                            Button("Make main location") {
                                Task { await viewModel.makeMain(location) }
                            }
                        }
                        Button("Delete", role: .destructive) {
                            locationToDelete = location
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
}
