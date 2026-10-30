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
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .refresh:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .login, .refresh, .logout:
            return .post
        }
    }
    
    var requiresAuthentication: Bool {
        false
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
        }
    }
}
