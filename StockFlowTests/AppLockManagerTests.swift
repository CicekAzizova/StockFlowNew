//
//  AppLockManagerTests.swift
//  StockFlow
//
//  Created by Cicek on 30.10.26.
//

import Testing
import Foundation
@testable import StockFlow

@MainActor
struct AppLockManagerTests {

    private func makeSUT(
        pin: String? = nil,
        biometrics: MockBiometrics? = nil,
        defaults: UserDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
    ) -> (manager: AppLockManager, store: MockPinStore, biometrics: MockBiometrics) {
        let store = MockPinStore()
        let bio = biometrics ?? MockBiometrics()
        if let pin { try? store.savePin(pin) }
        let manager = AppLockManager(pinStore: store, biometrics: bio, defaults: defaults)
        return (manager, store, bio)
    }

    // MARK: - Başlanğıc vəziyyət

    @Test func startsUnlockedWhenNoPin() {
        let sut = makeSUT()
        #expect(sut.manager.isPinEnabled == false)
        #expect(sut.manager.isLocked == false)
    }

    @Test func startsLockedWhenPinExists() {
        let sut = makeSUT(pin: "1234")
        #expect(sut.manager.isPinEnabled == true)
        #expect(sut.manager.isLocked == true)
    }

    // MARK: - PIN

    @Test func correctPinUnlocks() {
        let sut = makeSUT(pin: "1234")
        #expect(sut.manager.unlock(with: "1234") == true)
        #expect(sut.manager.isLocked == false)
    }

    @Test func wrongPinStaysLockedAndCountsAttempt() {
        let sut = makeSUT(pin: "1234")
        #expect(sut.manager.unlock(with: "0000") == false)
        #expect(sut.manager.isLocked == true)
        #expect(sut.manager.attemptsLeft == AppLockManager.maxAttempts - 1)
    }

    @Test func attemptsLeftReachesZeroAfterMaxWrongPins() {
        let sut = makeSUT(pin: "1234")
        for _ in 0..<AppLockManager.maxAttempts {
            _ = sut.manager.unlock(with: "0000")
        }
        #expect(sut.manager.attemptsLeft == 0)
    }

    @Test func correctPinResetsAttempts() {
        let sut = makeSUT(pin: "1234")
        _ = sut.manager.unlock(with: "0000")
        _ = sut.manager.unlock(with: "1234")
        #expect(sut.manager.attemptsLeft == AppLockManager.maxAttempts)
    }

    @Test func attemptsSurviveRecreation() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let first = makeSUT(pin: "1234", defaults: defaults)
        _ = first.manager.unlock(with: "0000")
        _ = first.manager.unlock(with: "0000")

        let second = makeSUT(pin: "1234", defaults: defaults)
        #expect(second.manager.attemptsLeft == AppLockManager.maxAttempts - 2)
    }

    @Test func enablePinSavesPinAndResetsAttempts() throws {
        let sut = makeSUT(pin: "1234")
        _ = sut.manager.unlock(with: "0000")

        try sut.manager.enablePin("5678")

        #expect(sut.store.savedPin == "5678")
        #expect(sut.manager.isPinEnabled == true)
        #expect(sut.manager.attemptsLeft == AppLockManager.maxAttempts)
    }

    @Test func enablePinFailureKeepsPinDisabled() {
        let sut = makeSUT()
        sut.store.shouldThrowOnSave = true

        #expect(throws: TestError.self) {
            try sut.manager.enablePin("1234")
        }
        #expect(sut.manager.isPinEnabled == false)
    }

    @Test func disablePinClearsEverything() async {
        let sut = makeSUT(pin: "1234")
        sut.manager.setBiometrics(true)
        _ = sut.manager.unlock(with: "0000")

        sut.manager.disablePin()

        #expect(sut.store.hasPin == false)
        #expect(sut.manager.isPinEnabled == false)
        #expect(sut.manager.isLocked == false)
        #expect(sut.manager.isBiometricsEnabled == false)
        #expect(sut.manager.attemptsLeft == AppLockManager.maxAttempts)
    }

    // MARK: - Face ID

    @Test func biometricsCannotBeEnabledWithoutPin() {
        let sut = makeSUT()
        sut.manager.setBiometrics(true)
        #expect(sut.manager.isBiometricsEnabled == false)
    }

    @Test func biometricsCannotBeEnabledWhenUnavailable() {
        let sut = makeSUT(pin: "1234", biometrics: MockBiometrics(isAvailable: false))
        sut.manager.setBiometrics(true)
        #expect(sut.manager.isBiometricsEnabled == false)
    }

    @Test func biometricsUnlockSucceeds() async {
        let sut = makeSUT(pin: "1234")
        sut.manager.setBiometrics(true)

        let result = await sut.manager.unlockWithBiometrics()

        #expect(result == true)
        #expect(sut.manager.isLocked == false)
    }

    @Test func biometricsUnlockFailureKeepsLocked() async {
        let sut = makeSUT(pin: "1234", biometrics: MockBiometrics(authenticateResult: false))
        sut.manager.setBiometrics(true)

        let result = await sut.manager.unlockWithBiometrics()

        #expect(result == false)
        #expect(sut.manager.isLocked == true)
    }

    @Test func biometricsUnlockDoesNothingWhenDisabled() async {
        let sut = makeSUT(pin: "1234")

        let result = await sut.manager.unlockWithBiometrics()

        #expect(result == false)
        #expect(sut.biometrics.authenticateCallCount == 0)
    }

    @Test func enableBiometricsRequiresSuccessfulAuthentication() async {
        let sut = makeSUT(pin: "1234", biometrics: MockBiometrics(authenticateResult: false))

        await sut.manager.enableBiometrics()

        #expect(sut.manager.isBiometricsEnabled == false)
    }
}
