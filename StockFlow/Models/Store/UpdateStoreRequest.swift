//
//  UpdateStoreRequest.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

/// Mağazanı dəyişmək üçün sorğu. Yalnız dolu (nil olmayan) sahələr göndərilir.
struct UpdateStoreRequest: Encodable {
    var name: String? = nil
    var phone: String? = nil
    var currency: String? = nil
    var mainCategories: [String]? = nil
    var country: String? = nil
    var city: String? = nil
    var timezone: String? = nil
    var onboardingCompleted: Bool? = nil

    enum CodingKeys: String, CodingKey {
        case name, phone, currency, country, city, timezone
        case mainCategories = "main_categories"
        case onboardingCompleted = "onboarding_completed"
    }
}
