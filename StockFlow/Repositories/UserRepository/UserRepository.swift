//
//  UserRepository.swift
//  StockFlow
//
//  Created by Cicek on 25.09.26.
//

import Foundation

protocol UserRepository {
    func getUser() async throws -> User
    func updateProfile(name: String, surname: String, phone: String) async throws -> User
    func uploadAvatar(_ imageData: Data) async throws -> User
    func deleteAvatar() async throws -> User
    func changePassword(current: String, new: String) async throws
    func deleteAccount(password: String) async throws
}

final class DefaultUserRepository: UserRepository {
    
    private let networkService: NetworkService
    
    private let tokenStorage: TokenStoring
    
    
    init(networkService: NetworkService, tokenStorage: TokenStoring) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func getUser() async throws -> User {
        try await networkService.request(UserEndpoint.getProfile)
    }
    
    func updateProfile(name: String, surname: String, phone: String) async throws -> User {
        let request = UpdateProfileRequest(name: name, surname: surname, phone: phone)
        return try await networkService.request(UserEndpoint.editProfile(request))
    }
    
    func uploadAvatar(_ imageData: Data) async throws -> User {
        try await networkService.upload(
            UserEndpoint.uploadProfileAvatar,
            fileData: imageData,
            fieldName: "image",
            fileName: "avatar.jpg",
            mimeType: "image/jpeg"
        )
    }
    
    func deleteAvatar() async throws -> User {
        try await networkService.request(UserEndpoint.deleteProfileAvatar)
    }
    
    func changePassword(current: String, new: String) async throws {
        let request = ChangePasswordRequest(currentPassword: current, newPassword: new)
        let response: ChangePasswordResponse = try await networkService.request(
            UserEndpoint.changePassword(request)
        )
        // Server köhnə tokenləri ləğv edir. Yenilərini saxlamasaq, növbəti sorğuda logout olar.
        try tokenStorage.saveToken(response.token)
        try tokenStorage.saveRefreshToken(response.refreshToken)
    }
    
    func deleteAccount(password: String) async throws {
        try await networkService.requestVoid(
            UserEndpoint.deleteAccount(DeleteAccountRequest(password: password))
        )
    }
}
