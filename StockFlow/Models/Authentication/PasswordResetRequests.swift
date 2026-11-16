//
//  PasswordResetRequests.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import Foundation

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let newPassword: String

    enum CodingKeys: String, CodingKey {
        case email
        case code
        case newPassword = "new_password"
    }
}
