//
//  ReportLocationMenu.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Başlıqda məkan seçimi: "Bütün məkanlar" və ya konkret məkan.
struct ReportLocationMenu: View {

    let locations: [StoreLocation]
    @Binding var selectedId: Int?

    private var selected: StoreLocation? {
        locations.first { $0.id == selectedId }
    }

    var body: some View {
        Menu {
            Button {
                selectedId = nil
            } label: {
                if selectedId == nil {
                    Label("All locations", systemImage: "checkmark")
                } else {
                    Text("All locations")
                }
            }

            ForEach(locations) { location in
                Button {
                    selectedId = location.id
                } label: {
                    if location.id == selectedId {
                        Label {
                            Text(verbatim: location.name)
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Text(verbatim: location.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")

                if let selected {
                    Text(verbatim: selected.name)
                } else {
                    Text("All locations")
                }

                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.15), in: Capsule())
        }
    }
}
