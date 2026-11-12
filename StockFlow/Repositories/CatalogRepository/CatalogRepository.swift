//
//  CatalogRepository.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

protocol CatalogRepository {
    func getCategories() async throws -> [CatalogCategory]
}

final class DefaultCatalogRepository: CatalogRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getCategories() async throws -> [CatalogCategory] {
        let response: CatalogResponse = try await networkService.request(CatalogEndpoint.categories)
        return response.categories
    }
}
