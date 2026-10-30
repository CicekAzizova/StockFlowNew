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
    private(set) var failedAttempts: Int
    
    static let maxAttempts = 5
    static let gracePeriod: Duration = .seconds(10)
    
    private var backgroundedAt: ContinuousClock.Instant?
    private let pinStore: PinStoring
    private let biometrics: BiometricAuthenticating
    private let defaults: UserDefaults
    private let biometricKey = "biometrics_enabled"
    private let attemptsKey = "pin_failed_attempts"

    
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
        self.failedAttempts = defaults.integer(forKey: attemptsKey)
    }
    
    var canUseBiometrics: Bool {
        biometrics.isAvailable
    }
    
    var attemptsLeft: Int {
        max(Self.maxAttempts - failedAttempts, 0)
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
        guard pinStore.verify(pin) else {
            registerFailedAttempt()
            return false
        }
        resetAttempts()
        isLocked = false
        return true
    }
    
    private func registerFailedAttempt() {
        failedAttempts += 1
        defaults.set(failedAttempts, forKey: attemptsKey)
    }
    
    private func resetAttempts() {
        failedAttempts = 0
        defaults.removeObject(forKey: attemptsKey)
    }
    
    func enablePin(_ pin: String) throws {
        try pinStore.savePin(pin)
        resetAttempts()
        isPinEnabled = true
    }
    
    func appDidEnterBackground() {
        guard pinStore.hasPin, !isLocked else { return }
        backgroundedAt = .now
    }
    
    func appDidBecomeActive() {
        defer { backgroundedAt = nil }
        
        guard let backgroundedAt, pinStore.hasPin else { return }
        
        if .now - backgroundedAt >= Self.gracePeriod {
            isLocked = true
        }
    }
    
    func disablePin() {
        pinStore.deletePin()
        resetAttempts()
        isLocked = false
        isPinEnabled = false
        setBiometrics(false)
    }
}
