//
//  LocationsStepView.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

extension LocationKind {
    var title: LocalizedStringKey {
        switch self {
        case .store: "Store"
        case .warehouse: "Warehouse"
        }
    }

    var icon: String {
        switch self {
        case .store: "storefront"
        case .warehouse: "shippingbox"
        }
    }

    var tint: Color {
        switch self {
        case .store: Color.brandTeal
        case .warehouse: Color.purple
        }
    }
}

struct LocationsStepView: View {

    let viewModel: OnboardingViewModel
    @State private var isAddPresented = false
    @State private var locationToDelete: StoreLocation?
    @State private var actionError: String?

    private var storeCount: Int {
        viewModel.locations.filter { $0.kind == .store }.count
    }

    private var warehouseCount: Int {
        viewModel.locations.filter { $0.kind == .warehouse }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stock is tracked separately for each location. Add all your stores and warehouses.")
                .font(.inter(.regular, size: 15))
                .foregroundStyle(.textSecondary)

            HStack(spacing: 12) {
                countTile(value: storeCount, title: "Stores", kind: .store)
                countTile(value: warehouseCount, title: "Warehouses", kind: .warehouse)
            }

            ForEach(viewModel.locations) { location in
                locationCard(location)
            }

            addButton
        }
        .task {
            if viewModel.locations.isEmpty {
                await viewModel.loadLocations()
            }
        }
        .sheet(isPresented: $isAddPresented) {
            AddLocationSheet(
                locationRepository: viewModel.locationRepository,
                onAdded: { await viewModel.loadLocations() }
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
                Task { actionError = await viewModel.deleteLocation(location) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { location in
            Text(verbatim: location.name)
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { actionError != nil },
                set: { if !$0 { actionError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(verbatim: actionError ?? "")
        }
    }

    // MARK: - Say kartları

    private func countTile(value: Int, title: LocalizedStringKey, kind: LocationKind) -> some View {
        HStack(spacing: 12) {
            Image(systemName: kind.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(kind.tint)
                .frame(width: 36, height: 36)
                .background(kind.tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "\(value)")
                    .font(.inter(.bold, size: 20))
                    .foregroundStyle(.textPrimary)
                Text(title)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Məkan kartı

    private func locationCard(_ location: StoreLocation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: location.kind.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(location.kind.tint)
                .frame(width: 44, height: 44)
                .background(location.kind.tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: location.name)
                    .font(.inter(.bold, size: 16))
                    .foregroundStyle(.textPrimary)

                if !location.address.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(verbatim: location.address)
                            .lineLimit(1)
                    }
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
                }

                HStack(spacing: 6) {
                    if location.isMain {
                        badge("Main", systemImage: "star.fill", color: Color.brandTeal)
                    }
                    badge(location.kind.title, color: location.kind.tint)
                }
            }
            Spacer(minLength: 0)

            if !location.isMain {
                Menu {
                    if location.kind == .store {
                        Button {
                            Task { actionError = await viewModel.makeMainLocation(location) }
                        } label: {
                            Label("Make main", systemImage: "star")
                        }
                    }
                    Button(role: .destructive) {
                        locationToDelete = location
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.textSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }        }
        .padding(14)
        .background(Color.surface)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(location.isMain ? Color.brandTeal : Color.gray.opacity(0.25),
                        lineWidth: location.isMain ? 1.5 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func badge(_ title: LocalizedStringKey, systemImage: String? = nil, color: Color) -> some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 9))
            }
            Text(title)
                .font(.inter(.bold, size: 11))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Əlavə et düyməsi

    private var addButton: some View {
        Button {
            isAddPresented = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text("Add store or warehouse")
            }
            .font(.inter(.bold, size: 15))
            .foregroundStyle(Color.brandTeal)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.brandTeal.opacity(0.6),
                                  style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            }
        }
        .buttonStyle(.plain)
    }
}
