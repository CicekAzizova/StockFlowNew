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
    
    private let decoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    init(session: URLSession = .shared, tokenStoring: TokenStoring) {
        self.session = session
        self.tokenStoring = tokenStoring
    }
    
    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        
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
            break
            
        case 401:
            throw unauthorizedError(data: data, endpoint: endpoint)
            
        default:
            let message = (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode, message: message
            )
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func requestVoid(_ endpoint: Endpoint) async throws {
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

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: HttpHeader.authorization
            )
        }
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
            return

        case 401:
            throw unauthorizedError(data: data, endpoint: endpoint)

        default:
            let message = (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode, message: message
            )
        }
    }
    
    func upload<T: Decodable>(
        _ endpoint: Endpoint,
        fileData: Data,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) async throws -> T {
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

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: HttpHeader.contentType
        )
        request.httpBody = makeMultipartBody(
            boundary: boundary,
            fileData: fileData,
            fieldName: fieldName,
            fileName: fileName,
            mimeType: mimeType
        )

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
            break
        case 401:
            throw unauthorizedError(data: data, endpoint: endpoint)
        default:
            let message = (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    //MARK: - Helpers
    private func unauthorizedError(data: Data, endpoint: Endpoint) -> NetworkError {
        if endpoint.requiresAuthentication {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        }
        let message = (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
        return .unauthorized(message: message)
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
