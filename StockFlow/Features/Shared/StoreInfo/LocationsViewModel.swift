//
//  LocationsViewModel.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

@MainActor
@Observable
final class LocationsViewModel {

    private let locationRepository: LocationRepository

    var locations: [StoreLocation] = []
    var errorMessage: String?

    init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }

    var repository: LocationRepository { locationRepository }

    func load() async {
        do {
            locations = try await locationRepository.getLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Əlavə edildikdən sonra siyahını yeniləyir və digər ekranlara xəbər verir.
    func reloadAfterChange() async {
        await load()
        NotificationCenter.default.post(name: .locationsChanged, object: nil)
    }

    func delete(_ location: StoreLocation) async {
        errorMessage = nil
        do {
            try await locationRepository.deleteLocation(id: location.id)
            await reloadAfterChange()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeMain(_ location: StoreLocation) async {
        errorMessage = nil
        do {
            _ = try await locationRepository.updateLocation(
                id: location.id,
                UpdateLocationRequest(isMain: true)
            )
            await reloadAfterChange()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
