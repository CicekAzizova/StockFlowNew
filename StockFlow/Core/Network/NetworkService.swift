//
//  NetworkService.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    
    func requestVoid(_ endpoint: Endpoint) async throws
    
    func upload<T: Decodable>(_ endpoint: Endpoint, fileData: Data,
                                  fieldName: String, fileName: String,
                                  mimeType: String) async throws -> T
}

final class DefaultNetworkService: NetworkService {

    private let session: URLSession
    private let tokenStoring: TokenStoring
    private let tokenRefresher: TokenRefreshing

    private let decoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()

    init(
        session: URLSession = .shared,
        tokenStoring: TokenStoring,
        tokenRefresher: TokenRefreshing
    ) {
        self.session = session
        self.tokenStoring = tokenStoring
        self.tokenRefresher = tokenRefresher
    }

    // MARK: - Public API

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await send(endpoint) { _ in }
        return try decode(data)
    }

    func requestVoid(_ endpoint: Endpoint) async throws {
        _ = try await send(endpoint) { _ in }
    }

    func upload<T: Decodable>(
        _ endpoint: Endpoint,
        fileData: Data,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) async throws -> T {
        let boundary = UUID().uuidString
        let body = makeMultipartBody(
            boundary: boundary,
            fileData: fileData,
            fieldName: fieldName,
            fileName: fileName,
            mimeType: mimeType
        )

        let data = try await send(endpoint) { request in
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: HttpHeader.contentType
            )
            request.httpBody = body
        }
        return try decode(data)
    }

    // MARK: - Send with automatic token refresh

    /// Sorğunu göndərir. Giriş token-i bitibsə (401), token-i yeniləyir və sorğunu bir dəfə təkrarlayır.
    private func send(
        _ endpoint: Endpoint,
        configure: (inout URLRequest) -> Void
    ) async throws -> Data {
        do {
            return try await perform(endpoint, configure: configure)
        } catch NetworkError.unauthorized(let message) where endpoint.requiresAuthentication {
            do {
                try await tokenRefresher.refresh()
            } catch NetworkError.unauthorized {
                // Refresh token da keçərsizdir: istifadəçi yenidən daxil olmalıdır.
                expireSession()
                throw NetworkError.unauthorized(message: message)
            }
            // Digər xətalar (internet yoxdur, server xətası) olduğu kimi atılır, logout olmur.

            do {
                return try await perform(endpoint, configure: configure)
            } catch NetworkError.unauthorized(let message) {
                expireSession()
                throw NetworkError.unauthorized(message: message)
            }
        }
    }

    /// Bir sorğu göndərir, təkrar və ya yeniləmə yoxdur.
    private func perform(
        _ endpoint: Endpoint,
        configure: (inout URLRequest) -> Void
    ) async throws -> Data {
        var request: URLRequest

        do {
            request = try endpoint.makeRequest()
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }

        if endpoint.requiresAuthentication {
            guard let token = try tokenStoring.readToken() else {
                throw KeychainServiceError.missingToken
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
        }

        configure(&request)

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
            return data
        case 401:
            throw NetworkError.unauthorized(message: serverMessage(from: data))
        default:
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage(from: data)
            )
        }
    }

    // MARK: - Helpers

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    private func serverMessage(from data: Data) -> String? {
        (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
    }

    private func expireSession() {
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
    }

    private func makeMultipartBody(
        boundary: String,
        fileData: Data,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        return body
    }
}

private struct ServerMessage: Decodable {
    let message: String
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
