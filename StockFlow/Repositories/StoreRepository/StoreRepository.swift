//
//  StoreRepository.swift
//  StockFlow
//
//  Created by Cicek on 23.09.26.
//

protocol StoreRepository {
    func createStore(_ request: StoreRequest) async throws -> StoreResponse
    func updateCurrency(_ currency: String) async throws -> StoreDetailsResponse
}

final class DefaultStoreRepository: StoreRepository {
    
    private let networkService: NetworkService
    private let tokenStorage: TokenStoring

    init(networkService: NetworkService, tokenStorage: TokenStoring) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func createStore(_ request: StoreRequest) async throws -> StoreResponse {
        let response: StoreResponse = try await networkService.request(StoreEndpoint.createStore(request))
        guard !response.token.isEmpty else { throw NetworkError.invalidResponse }
        try tokenStorage.saveToken(response.token)
        guard !response.refreshToken.isEmpty else { throw NetworkError.invalidResponse }
        try tokenStorage.saveRefreshToken(response.refreshToken)
        return response
    }
    
    func updateCurrency(_ currency: String) async throws -> StoreDetailsResponse {
        try await networkService.request(StoreEndpoint.updateCurrency(currency))
    }
}
