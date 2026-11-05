//
//  CreateStoreViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.09.26.
//

import Foundation

@MainActor
@Observable

final class CreateStoreViewModel {
    
    var state: CreateStoreViewState = .idle
    
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var password: String = ""
    var phone: String = ""
    var storeName: String = ""
    var storePhone: String = ""
    var storeAddress: String = ""
    
    var fieldErrors: [CreateStoreFocusedField: String] = [:]
    
    private let storeRepository: StoreRepository
    private let appStateManager: AppStateManager
    
    init(storeRepository: StoreRepository, appStateManager: AppStateManager) {
        self.storeRepository = storeRepository
        self.appStateManager = appStateManager
    }
    
    func createStore() async {
        guard validateFields() else { return }
        
        state = .loading
        let request = StoreRequest(
                name: name,
                surname: surname,
                email: email,
                password: password,
                phone: phone,
                storeName: storeName,
                storeAddress: storeAddress,
                storePhone: storePhone
            )
        do {
            let response = try await storeRepository.createStore(request)
            
            state = .success(response)
            await appStateManager.readToken()
        } catch  {
            state = .error(error.localizedDescription)
        }
    }
    
    
    private func validateFields() -> Bool {
        fieldErrors.removeAll()

        if name.isBlank {
            fieldErrors[.name] = "Full name is required."
        }

        if email.isBlank {
            fieldErrors[.email] = "Email is required."
        } else if !email.isValidEmail {
            fieldErrors[.email] = "Enter a valid email."
        }

        if password.isEmpty {
            fieldErrors[.password] = "Password is required."
        } else if password.count < 6 {
            fieldErrors[.password] = "Password must contain at least 6 characters."
        }

        if phone.isBlank {
            fieldErrors[.phone] = "Phone is required."
        }

        if storeName.isBlank {
            fieldErrors[.storeName] = "Store name is required."
        }

        if storeAddress.isBlank {
            fieldErrors[.storeAddress] = "Store address is required."
        }

        if storePhone.isBlank {
            fieldErrors[.storePhone] = "Store phone is required."
        }

        return fieldErrors.isEmpty
    }
}
