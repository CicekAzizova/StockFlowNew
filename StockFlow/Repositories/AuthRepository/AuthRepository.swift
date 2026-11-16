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
    func verifyEmail(code: String) async throws
    func resendVerification() async throws
    func forgotPassword(email: String) async throws
    func resetPassword(email: String, code: String, newPassword: String) async throws
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
    
    func verifyEmail(code: String) async throws {
        try await networkService.requestVoid(AuthEndpoint.verifyEmail(code: code))
    }

    func resendVerification() async throws {
        try await networkService.requestVoid(AuthEndpoint.resendVerification)
    }
    
    func forgotPassword(email: String) async throws {
        try await networkService.requestVoid(AuthEndpoint.forgotPassword(email: email))
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        try await networkService.requestVoid(
            AuthEndpoint.resetPassword(email: email, code: code, newPassword: newPassword)
        )
    }
}
