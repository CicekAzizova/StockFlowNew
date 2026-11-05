//
//  ProfileRequests.swift
//  StockFlow
//
//  Created by Cicek on 02.11.26.
//

import Foundation

struct UpdateProfileRequest: Encodable {
    let name: String
    let surname: String
    let phone: String
}

struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String

    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
}

/// Şifrə dəyişəndə server bütün cihazları çıxarır və cari cihaza yeni sessiya verir.
struct ChangePasswordResponse: Decodable {
    let token: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
    }
}

struct DeleteAccountRequest: Encodable {
    let password: String
}
