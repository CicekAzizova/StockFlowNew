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
    private(set) var hasSkippedPinSetup: Bool
    
    static let maxAttempts = 5
    static let gracePeriod: Duration = .seconds(10)
    
    /// Blok bitənə qədər qalan saniyə (0 = blok yoxdur). Ekran saniyədə bir yeniləyir.
    private(set) var lockoutSecondsLeft = 0

    /// Neçə dəfə blok olunub: hər dəfə müddət artır.
    private var lockoutCount: Int
    private var lockoutUntil: Date?
    
    private var backgroundedAt: ContinuousClock.Instant?
    private let pinStore: PinStoring
    private let biometrics: BiometricAuthenticating
    private let defaults: UserDefaults
    private let biometricKey = "biometrics_enabled"
    private let attemptsKey = "pin_failed_attempts"
    private let skipKey = "pin_setup_skipped"
    private let lockoutUntilKey = "pin_lockout_until"
    private let lockoutCountKey = "pin_lockout_count"
    
    
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
        self.hasSkippedPinSetup = defaults.bool(forKey: skipKey)
        self.lockoutCount = defaults.integer(forKey: lockoutCountKey)
        let until = defaults.object(forKey: lockoutUntilKey) as? Date
        self.lockoutUntil = until
        self.lockoutSecondsLeft = Self.secondsLeft(until: until)
    }
    
    var canUseBiometrics: Bool {
        biometrics.isAvailable
    }
    
    var attemptsLeft: Int {
        max(Self.maxAttempts - failedAttempts, 0)
    }
    
    // MARK: - Giriş bloku

    /// Ardıcıl 5 səhvdən sonra gözləmə müddəti: 30 san, 1 dəq, 5 dəq, 15 dəq.
    private static let lockoutSteps: [Int] = [30, 60, 300, 900]

    var isLockedOut: Bool { lockoutSecondsLeft > 0 }

    private static func secondsLeft(until: Date?) -> Int {
        guard let until else { return 0 }
        return max(Int(until.timeIntervalSinceNow.rounded(.up)), 0)
    }

    /// Ekrandakı saniyəlik taymer bunu çağırır.
    func refreshLockout() {
        lockoutSecondsLeft = Self.secondsLeft(until: lockoutUntil)
        if lockoutSecondsLeft == 0, lockoutUntil != nil {
            lockoutUntil = nil
            defaults.removeObject(forKey: lockoutUntilKey)
            // Yeni cəhdlər üçün sayğac sıfırlanır, blok səviyyəsi isə qalır.
            failedAttempts = 0
            defaults.removeObject(forKey: attemptsKey)
        }
    }

    private func startLockout() {
        let step = Self.lockoutSteps[min(lockoutCount, Self.lockoutSteps.count - 1)]
        lockoutCount += 1
        defaults.set(lockoutCount, forKey: lockoutCountKey)

        let until = Date.now.addingTimeInterval(TimeInterval(step))
        lockoutUntil = until
        defaults.set(until, forKey: lockoutUntilKey)
        lockoutSecondsLeft = step
    }
    
    func setBiometrics(_ enabled: Bool) {
        isBiometricsEnabled = enabled && isPinEnabled && biometrics.isAvailable
        defaults.set(isBiometricsEnabled, forKey: biometricKey)
    }
    
    func unlockWithBiometrics() async ->  Bool {
        refreshLockout()
        guard isLocked, isBiometricsEnabled else { return false }
        let success = await biometrics.authenticate(
            reason: String(localized: "Unlock \(AppInfo.name)")
        )
        if success { isLocked = false }
        return success
    }
    
    func verifyBiometrics() async -> Bool {
        guard biometrics.isAvailable else { return false }
        return await biometrics.authenticate(
            reason: String(localized: "Enable Face ID for \(AppInfo.name)")
        )
    }

    func enableBiometrics() async {
        guard isPinEnabled else { return }
        if await verifyBiometrics() {
            setBiometrics(true)
        }
    }
    
    func unlock(with pin: String) -> Bool {
        refreshLockout()
        guard !isLockedOut else { return false }

        guard pinStore.verify(pin) else {
            registerFailedAttempt()
            if attemptsLeft == 0 {
                startLockout()
            }
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
        lockoutCount = 0
        lockoutUntil = nil
        lockoutSecondsLeft = 0
        defaults.removeObject(forKey: lockoutCountKey)
        defaults.removeObject(forKey: lockoutUntilKey)
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
    
    func skipPinSetup() {
        hasSkippedPinSetup = true
        defaults.set(true, forKey: skipKey)
    }

    func resetPinSetupSkip() {
        hasSkippedPinSetup = false
        defaults.removeObject(forKey: skipKey)
    }
}
