//
//  MockPinStore.swift
//  StockFlow
//
//  Created by Cicek on 30.10.26.
//

import Foundation
@testable import StockFlow

@MainActor
final class MockPinStore: PinStoring {
    private(set) var savedPin: String?
    var shouldThrowOnSave = false

    var hasPin: Bool { savedPin != nil }

    func savePin(_ pin: String) throws {
        if shouldThrowOnSave { throw TestError.failed }
        savedPin = pin
    }

    func verify(_ pin: String) -> Bool { savedPin == pin }

    func deletePin() { savedPin = nil }
}
