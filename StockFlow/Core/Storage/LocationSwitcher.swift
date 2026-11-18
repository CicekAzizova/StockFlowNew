//
//  LocationSwitcher.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

/// Sahibin işlədiyi məkanı seçən ortaq obyekt (Profile və Products eyni nüsxədən istifadə edir).
@MainActor
@Observable
final class LocationSwitcher {

    private let locationRepository: LocationRepository
    private let productsStore: ProductsStore
    private let salesStore: SalesStore

    var locations: [StoreLocation] = []
    var activeLocationId: Int? = ActiveLocationStore.id

    init(
        locationRepository: LocationRepository,
        productsStore: ProductsStore,
        salesStore: SalesStore
    ) {
        self.locationRepository = locationRepository
        self.productsStore = productsStore
        self.salesStore = salesStore
    }

    /// Seçilmiş məkan. Heç nə seçilməyibsə əsas məkan.
    var activeLocation: StoreLocation? {
        locations.first { $0.id == activeLocationId } ?? locations.first { $0.isMain }
    }

    /// Seçim yalnız 2 və daha çox məkan olanda mənalıdır.
    var canSwitch: Bool {
        locations.count > 1
    }

    func load() async {
        locations = (try? await locationRepository.getLocations()) ?? locations

        // Seçilmiş məkan silinibsə əsas məkana qayıdırıq.
        if let id = activeLocationId, !locations.contains(where: { $0.id == id }) {
            select(nil)
        }
    }

    /// nil = əsas məkan.
    func select(_ location: StoreLocation?) {
        let id = (location?.isMain == true) ? nil : location?.id
        guard id != activeLocationId else { return }
        ActiveLocationStore.id = id
        ActiveLocationStore.name = id == nil ? nil : location?.name
        activeLocationId = id

        // Qalıq məkandan asılıdır, köhnə siyahılar yenilənməlidir.
        productsStore.reset()
        salesStore.reset()
        NotificationCenter.default.post(name: .activeLocationChanged, object: nil)
    }
}
