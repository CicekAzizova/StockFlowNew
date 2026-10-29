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
    private(set) var isBiometricsEnabled: Bool
    
    private let pinStore: PinStoring
    private let biometrics: BiometricAuthenticating
    private let defaults: UserDefaults
    private let biometricKey = "biometrics_enabled"
    
    init(
        pinStore: PinStoring,
        biometrics: BiometricAuthenticating,
        defaults: UserDefaults = .standard
    ) {
        self.isLocked = pinStore.hasPin
        self.isPinEnabled = pinStore.hasPin
        self.isBiometricsEnabled = pinStore.hasPin && defaults.bool(forKey: biometricKey)
        self.pinStore = pinStore
        self.biometrics = biometrics
        self.defaults = defaults
    }
    
    var canUseBiometrics: Bool {
        biometrics.isAvailable
    }
    
    func setBiometrics(_ enabled: Bool) {
        isBiometricsEnabled = enabled && isPinEnabled && biometrics.isAvailable
        defaults.set(isBiometricsEnabled, forKey: biometricKey)
    }
    
    func unlockWithBiometrics() async ->  Bool {
        guard isLocked, isBiometricsEnabled else { return false }
        let success = await biometrics.authenticate(reason: "Unlock StockFlow")
        if success { isLocked = false }
        return success
    }
    
    func verifyBiometrics() async -> Bool {
        guard biometrics.isAvailable else { return false }
        return await biometrics.authenticate(reason: "Enable Face ID for StockFlow")
    }

    func enableBiometrics() async {
        guard isPinEnabled else { return }
        if await verifyBiometrics() {
            setBiometrics(true)
        }
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
        setBiometrics(false)
        isLocked = false
        isPinEnabled = false
    }
}
