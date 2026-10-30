//
//  KeychainWrapper.swift
//  StockFlow
//
//  Created by Cicek on 21.09.26.
//
import Foundation

protocol TokenStoring {
    func saveToken(_ token: String) throws
    func readToken() throws -> String?
    func deleteToken() throws
    
    func saveRefreshToken(_ token: String) throws
    func readRefreshToken() throws -> String?
    func deleteRefreshToken() throws
}

final class KeychainWrapper: TokenStoring {
    
    private let service: KeychainService
    
    init(service: KeychainService = KeychainService()){
        self.service = service
    }
    
    private enum Keys {
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
    }
    
    func saveToken(_ token: String) throws { try save(token, key: Keys.authToken) }
    
    func readToken() throws -> String? { try read(key: Keys.authToken)}
    
    func deleteToken() throws { try service.delete(for: Keys.authToken) }
    
    
    func saveRefreshToken(_ token: String) throws { try save(token, key: Keys.refreshToken) }
    
    func readRefreshToken() throws -> String? { try read(key: Keys.refreshToken)}
    
    func deleteRefreshToken() throws { try service.delete(for: Keys.refreshToken) }
    
    //MARK: - Helpers
    
    private func save(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainServiceError.invalidData
        }
        try service.save(data, for: key)
    }
    
    private func read(key: String) throws -> String? {
        guard let data = try service.read(for: key) else { return nil }
        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainServiceError.invalidData
        }
        return value
                
    }
}
