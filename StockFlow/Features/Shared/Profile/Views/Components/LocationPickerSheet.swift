//
//  LocationPickerSheet.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

struct LocationPickerSheet: View {

    let locations: [StoreLocation]
    let selectedId: Int?
    let onSelect: (StoreLocation) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(locations) { location in
                Button {
                    onSelect(location)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: location.kind == .store ? "storefront" : "shippingbox")
                            .foregroundStyle(Color.brandTeal)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text(verbatim: location.name)
                                    .foregroundStyle(Color.textPrimary)

                                if location.isMain {
                                    Text("Main")
                                        .font(.caption2.bold())
                                        .foregroundStyle(Color.brandTeal)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.brandTeal.opacity(0.12), in: Capsule())
                                }
                            }
                            if !location.address.isEmpty {
                                Text(verbatim: location.address)
                                    .font(.footnote)
                                    .foregroundStyle(.textSecondary)
                            }
                        }

                        Spacer()

                        if location.id == selectedId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.brandTeal)
                        }
                    }
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
