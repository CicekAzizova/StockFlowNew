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
    
    let associate: SalesAssociateResponse?
    
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
    
    init(repository: SalesAssociateRepository,associate: SalesAssociateResponse? = nil ) {
        self.repository = repository
        self.associate = associate
        
        guard let associate else { return }
        
        name = associate.name
        surname = associate.surname
        fin = associate.fin
        phone = associate.phone
        email = associate.email
        
    }
    var isEdit: Bool {
        associate != nil
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
    
    func updateSalesAssociate() async {
        
        guard let associate else { return }
        
        guard validateFields() else { return }
        state = .loading
        do {
            let response = try  await repository.updateSalesAssociate(
                id: associate.id,
                request: UpdateSalesAssociateRequest(
                    name: name.trimmed,
                    surname: surname.trimmed,
                    fin: fin.trimmed,
                    phone: phone.trimmed,
                    email: email.trimmed,
                    password: password.nilIfBlank
                )
            )
            state = .success(response)
        } catch {
            state = .error(error.localizedDescription)

        }
        
    }
    
    func save() async {
        if isEdit {
            await updateSalesAssociate()
        } else {
            await createSalesAssociate()
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

        
        if isEdit {
            if !password.isEmpty {
                if password.count < 6 {
                    passwordError = "Password must contain at least 6 characters."
                }
            }
        } else {
            if password.isEmpty {
                passwordError = "Password is required."
            } else if password.count < 6 {
                passwordError = "Password must contain at least 6 characters."
            }
        }
        
        return nameError == nil &&
                surnameError == nil &&
                emailError == nil &&
                passwordError == nil
    }
}
