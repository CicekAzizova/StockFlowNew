//
//  AddSalesAssociateViewModel.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

@Observable
@MainActor

final class AddSalesAssociateViewModel {
    
    private let repository: SalesAssociateRepository
    
    var state: AddSalesAssociateViewState = .idle
    
    var name: String = ""
    var surname: String = ""
    var fin: String = ""
    var phone: String = ""
    var email: String = ""
    var password: String = ""
    
    var nameError: String?
    var surnameError: String?
    var emailError: String?
    var passwordError: String?
    
    init(repository: SalesAssociateRepository) {
        self.repository = repository
    }
    
    func createSalesAssociate() async {
        guard validateFields() else { return }
        
        state = .loading
        
        do {
            let response = try await repository.addSalesAssociate(
                request: SalesAssociateRequest(
                    name: name,
                    surname: surname,
                    fin: fin,
                    phone: phone,
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            )
            state = .success(response)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func validateFields() -> Bool {
        nameError = nil
        surnameError = nil
        emailError = nil
        passwordError = nil

        if name.isBlank {
            nameError = "First name is required."
        }
        
        if surname.isBlank {
            surnameError = "Surname is required."
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            emailError = "Email is required."
        } else if !trimmedEmail.isValidEmail {
            emailError = "Enter a valid email."
        }

        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 6 {
            passwordError = "Password must contain at least 6 characters."
        }
        
        return nameError == nil &&
                surnameError == nil &&
                emailError == nil &&
                passwordError == nil
    }
}
