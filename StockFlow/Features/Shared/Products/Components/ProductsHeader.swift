//
//  ProductsHeader.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import SwiftUI

struct ProductsHeader: View {

    let locationSwitcher: LocationSwitcher?
    @Binding var query: String
    @Binding var filter: ProductStockFilter
    let stats: ProductStats?
    let onScan: () -> Void
    let activeFilterCount: Int
    let onFilter: () -> Void
    

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                if let locationSwitcher, locationSwitcher.canSwitch {
                    locationMenu(locationSwitcher)
                }

                Text("Products")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            HStack(spacing: 10) {
                BrandSearchField(
                    placeholder: "Name or barcode",
                    autoFocus: false,
                    text: $query
                )

                Button(action: onScan) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.brandTeal)
                        .frame(width: 44, height: 44)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .accessibilityLabel("Scan barcode")
                
                Button(action: onFilter) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.brandTeal)
                        .frame(width: 44, height: 44)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            if activeFilterCount > 0 {
                                Text(verbatim: "\(activeFilterCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.brandGreen, in: Circle())
                                    .offset(x: 5, y: -5)
                            }
                        }
                }
                .accessibilityLabel("Filter")
                
            }
            StockFilterChips(selected: $filter, stats: stats)

        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandHeaderBackground()
    }
    
    private func locationMenu(_ switcher: LocationSwitcher) -> some View {
        Menu {
            ForEach(switcher.locations) { location in
                Button {
                    switcher.select(location)
                } label: {
                    if location.id == switcher.activeLocation?.id {
                        Label(location.name, systemImage: "checkmark")
                    } else {
                        Text(verbatim: location.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                Text(verbatim: switcher.activeLocation?.name ?? "")
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.8))
        }
    }
}
