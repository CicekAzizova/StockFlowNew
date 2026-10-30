//
//  AuthRepository.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> LoginResponse
    func logout(refreshToken: String) async
}

final class DefaultAuthRepository: AuthRepository {
    
    private let networkService: NetworkService
    private let tokenStorage: TokenStoring
    
    init(networkService: NetworkService, tokenStorage: TokenStoring) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await networkService.request(AuthEndpoint.login(email: email, password: password))
        guard !response.token.isEmpty else { throw NetworkError.invalidResponse }
        try tokenStorage.saveToken(response.token)
        guard !response.refreshToken.isEmpty else { throw NetworkError.invalidResponse }
        try tokenStorage.saveRefreshToken(response.refreshToken)
        return response
    }
    
    func logout(refreshToken: String) async {
        try? await networkService.requestVoid(AuthEndpoint.logout(refreshToken: refreshToken))
    }
}
