//
//  TokenRefresher.swift
//  StockFlow
//
//  Created by Cicek on 30.10.26.
//

import Foundation

protocol TokenRefreshing {
    func refresh() async throws
}

final class TokenRefresher: TokenRefreshing {

    private let session: URLSession
    private let tokenStorage: TokenStoring
    private var inFlightTask: Task<Void, Error>?

    init(session: URLSession = .shared, tokenStorage: TokenStoring) {
        self.session = session
        self.tokenStorage = tokenStorage
    }

    /// Eyni anda neçə sorğu yeniləmək istəsə də, serverə yalnız bir sorğu gedir.  Single-flight pattern
    func refresh() async throws {
        if let inFlightTask {
            return try await inFlightTask.value
        }

        let task = Task { try await performRefresh() }
        inFlightTask = task
        defer { inFlightTask = nil }

        try await task.value
    }

    private func performRefresh() async throws {
        guard let refreshToken = try tokenStorage.readRefreshToken(),
              !refreshToken.isEmpty else {
            throw NetworkError.unauthorized(message: nil)
        }

        let request = try AuthEndpoint.refresh(refreshToken: refreshToken).makeRequest()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let tokens: RefreshResponse
            do {
                tokens = try JSONDecoder().decode(RefreshResponse.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
            try tokenStorage.saveToken(tokens.token)
            try tokenStorage.saveRefreshToken(tokens.refreshToken)

        case 401:
            throw NetworkError.unauthorized(message: nil)

        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
    }
}
