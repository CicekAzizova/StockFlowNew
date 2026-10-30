//
//  MockBiometrics.swift
//  StockFlow
//
//  Created by Cicek on 30.10.26.
//

import Foundation
@testable import StockFlow

@MainActor
final class MockBiometrics: BiometricAuthenticating {
    var isAvailable: Bool
    var authenticateResult: Bool
    private(set) var authenticateCallCount = 0

    init(isAvailable: Bool = true, authenticateResult: Bool = true) {
        self.isAvailable = isAvailable
        self.authenticateResult = authenticateResult
    }

    func authenticate(reason: String) async -> Bool {
        authenticateCallCount += 1
        return authenticateResult
    }
}
