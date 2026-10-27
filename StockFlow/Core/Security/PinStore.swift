//
//  PinStore.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//

import CryptoKit
import Foundation

protocol PinStoring {
    func savePin(_ pin: String) throws
    func verify(_ pin: String) -> Bool
    func deletePin()
    var hasPin: Bool { get }
}

final class KeychainPinStore: PinStoring {
    private let keychain: KeychainService
    private let account = "app_lock_pin"
    
    init(keychain: KeychainService) {
        self.keychain = keychain
    }
    
    var hasPin: Bool {
        (try? keychain.read(for: account)) != nil
    }
    
    func savePin(_ pin: String) throws {
        try keychain.save(hash(pin), for: account)
    }
    
    func verify(_ pin: String) -> Bool {
        guard let saved = try? keychain.read(for: account) else { return false }
        return saved == hash(pin)
    }
    
    func deletePin() {
        try? keychain.delete(for: account)
    }
    
    private func hash(_ pin: String) -> Data {
        Data(SHA256.hash(data: Data(pin.utf8)))
    }
}
