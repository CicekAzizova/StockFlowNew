//
//  UserEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 25.09.26.
//

import Foundation

import Foundation

enum UserEndpoint: Endpoint {
    
    case getProfile
    case editProfile(UpdateProfileRequest)
    case uploadProfileAvatar
    case deleteProfileAvatar
    case changePassword(ChangePasswordRequest)
    case deleteAccount(DeleteAccountRequest)
    
    var path: String {
        switch self {
        case .getProfile, .editProfile, .deleteAccount:
            "/users/me"
        case .uploadProfileAvatar, .deleteProfileAvatar:
            "/users/me/avatar"
        case .changePassword:
            "/auth/change-password"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .getProfile:
                .get
        case .editProfile:
                .patch
        case .uploadProfileAvatar, .changePassword:
                .post
        case .deleteProfileAvatar, .deleteAccount:
                .delete
        }
    }
    
    var httpBody: (any Encodable)? {
        switch self {
        case .editProfile(let request): request
        case .changePassword(let request): request
        case .deleteAccount(let request): request
        case .getProfile, .uploadProfileAvatar, .deleteProfileAvatar: nil
        }
    }
}
