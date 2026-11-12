//
//  User.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//
import Foundation

struct User: Decodable {
    let id: Int
    let email: String
    let name: String
    let role: UserRole
    var storeName: String?
    var surname: String?
    var phone: String?
    var avatarUrl: String?
    var currency: String? = nil
    
    var mainCategories: [String]? = nil
    
    var onboardingCompleted: Bool? = nil
    
    var fullName: String {
            [name, surname].compactMap { $0?.nilIfBlank }.joined(separator: " ")
        }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case role
        case currency
        case storeName = "store_name"
        case surname
        case phone
        case avatarUrl = "avatar_url"
        case mainCategories = "main_categories"
        case onboardingCompleted = "onboarding_completed"
    }
}
