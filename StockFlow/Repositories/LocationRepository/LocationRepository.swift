//
//  LocationRepository.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

protocol LocationRepository {
    func getLocations() async throws -> [StoreLocation]
    func createLocation(_ request: CreateLocationRequest) async throws -> StoreLocation
    func updateLocation(id: Int, _ request: UpdateLocationRequest) async throws -> StoreLocation
    func deleteLocation(id: Int) async throws
}

final class DefaultLocationRepository: LocationRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getLocations() async throws -> [StoreLocation] {
        try await networkService.request(LocationEndpoint.list)
    }

    func createLocation(_ request: CreateLocationRequest) async throws -> StoreLocation {
        try await networkService.request(LocationEndpoint.create(request))
    }

    func updateLocation(id: Int, _ request: UpdateLocationRequest) async throws -> StoreLocation {
        try await networkService.request(LocationEndpoint.update(id: id, request: request))
    }
    
    func deleteLocation(id: Int) async throws {
        try await networkService.requestVoid(LocationEndpoint.delete(id: id))
    }
}
