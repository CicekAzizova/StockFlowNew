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
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .login, .refresh, .logout, .verifyEmail, .resendVerification:
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
        case .resendVerification:
            return nil
        }
        
    }
}
