//
//  MockUserRepository.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import Foundation
@testable import StockFlow

@MainActor
final class MockUserRepository: UserRepository {
    var result: Result<User, Error> = .success(TestData.owner)
    var changePasswordResult: Result<Void, Error> = .success(())
    var deleteAccountResult: Result<Void, Error> = .success(())

    private(set) var updateProfileCalls: [(name: String, surname: String, phone: String)] = []
    private(set) var changePasswordCalls: [(current: String, new: String)] = []
    private(set) var deleteAccountCalls: [String] = []

    func getUser() async throws -> User {
        try result.get()
    }

    func updateProfile(name: String, surname: String, phone: String) async throws -> User {
        updateProfileCalls.append((name, surname, phone))
        return try result.get()
    }

    func uploadAvatar(_ imageData: Data) async throws -> User {
        try result.get()
    }

    func deleteAvatar() async throws -> User {
        try result.get()
    }

    func changePassword(current: String, new: String) async throws {
        changePasswordCalls.append((current, new))
        try changePasswordResult.get()
    }

    func deleteAccount(password: String) async throws {
        deleteAccountCalls.append(password)
        try deleteAccountResult.get()
    }
}
