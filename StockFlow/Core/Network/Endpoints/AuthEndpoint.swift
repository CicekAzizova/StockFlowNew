//
//  AuthEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    
    case login(email: String,password: String)
    case refresh(refreshToken: String)
    case logout(refreshToken: String)
    case verifyEmail(code: String)
    case resendVerification
    case forgotPassword(email: String)
    case resetPassword(email: String, code: String, newPassword: String)
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .refresh:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .verifyEmail:
            return "/auth/verify-email"
        case .resendVerification:
            return "/auth/resend-verification"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .resetPassword:
            return "/auth/reset-password"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .login, .refresh, .logout, .verifyEmail, .resendVerification, .forgotPassword, .resetPassword:
            return .post
        }
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .verifyEmail, .resendVerification:
            return true
        default:
            return false
        }
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .login(let email, let password):
            return LoginRequest(
                email: email,
                password: password
            )
        case .refresh(let refreshToken), .logout(let refreshToken):
            return RefreshRequest(refreshToken: refreshToken)
        case .verifyEmail(let code):
            return VerifyEmailRequest(code: code)
        case .forgotPassword(let email):
            return ForgotPasswordRequest(email: email)
        case .resetPassword(let email, let code, let newPassword):
            return ResetPasswordRequest(email: email, code: code, newPassword: newPassword)
        case .resendVerification:
            return nil
        }
        
    }
}
