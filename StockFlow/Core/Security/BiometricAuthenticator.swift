//
//  BiometricAuthenticator.swift
//  StockFlow
//
//  Created by Cicek on 28.10.26.
//
import LocalAuthentication

protocol BiometricAuthenticating {
    var isAvailable: Bool { get }
    func authenticate(reason: String) async -> Bool
}

final class BiometricAuthenticator: BiometricAuthenticating {
    
    var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        }
        catch {
            return false
        }
        return true
    }
}
