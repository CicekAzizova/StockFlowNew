//
//  AppStateManager.swift
//  StockFlow
//
//  Created by Cicek on 24.09.26.
//

import Foundation
import Observation

@Observable
final class  AppStateManager {
    var state: AppState = .loading
    var user: User?
    
    var onLogout: (() -> Void)?
    var onRevokeSession: ((String) -> Void)?
    
    private let tokenStorage: TokenStoring
    private let userRepository: UserRepository
    
    init(
        tokenStorage: TokenStoring,
        userRepository: UserRepository
    ) {
        self.tokenStorage = tokenStorage
        self.userRepository = userRepository
    }
    
    func setUser(_ user: User) {
        self.user = user
        state = .authenticated
    }
    
    func readToken() async {
        state = .loading
        do {
            let token = try  tokenStorage.readToken()
            
            guard let token , !token.isEmpty else {
                user = nil
                state = .unauthenticated
                return
            }
            let currentUser = try await userRepository.getUser()
            setUser(currentUser)
            
        } catch  {
            state = .unauthenticated
        }
    }
    
    func logout() {
        
        guard state == .authenticated else { return }
        let refreshToken = try? tokenStorage.readRefreshToken()
        
        try? tokenStorage.deleteToken()
        try? tokenStorage.deleteRefreshToken()
        
        user = nil
        onLogout?()
        state = .unauthenticated
        
        if let refreshToken {
           onRevokeSession?(refreshToken)
        }
    }
}
