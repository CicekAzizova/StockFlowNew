//
//  MockAuthRepository.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import Foundation 
@testable import StockFlow

@MainActor
final class MockAuthRepository: AuthRepository {
    var result: Result<LoginResponse, Error>
    private(set) var loginCallCount = 0
    private(set) var logoutCalls: [String] = []

    init(result: Result<LoginResponse, Error>) {
        self.result = result
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        loginCallCount += 1
        return try result.get()
    }

    func logout(refreshToken: String) async {
        logoutCalls.append(refreshToken)
    }
}
