//
//  AppLockManager.swift
//  StockFlow
//
//  Created by Cicek on 27.10.26.
//
import Foundation


@Observable
final class AppLockManager {
    private(set) var isLocked: Bool
    private(set) var isPinEnabled: Bool
    
    private let pinStore: PinStoring
    
    init(pinStore: PinStoring) {
        self.isPinEnabled = pinStore.hasPin
        self.isLocked = pinStore.hasPin
        self.pinStore = pinStore
    }
    
    func lockIfNeeded() {
        if pinStore.hasPin {
            isLocked = true
        }
    }
    
    func unlock(with pin: String) -> Bool {
        guard pinStore.verify(pin) else { return false }
        isLocked = false
        return true
    }
    
    func enablePin(_ pin: String) throws {
        try pinStore.savePin(pin)
        isPinEnabled = true
    }
    
    func disablePin() {
        pinStore.deletePin()
        isLocked = false
        isPinEnabled = false
    }
}
