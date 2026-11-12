//
//  AppLanguage.swift
//  StockFlow
//
//  Created by Cicek on 28.10.26.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case azerbaijani = "az-AZ"
    case russian = "ru"
    case turkish = "tr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english:
            "English"
        case .azerbaijani:
            "Azərbaycanca"
        case .russian:
            "Русский"
        case .turkish:
            "Türkçe"
        }
    }
    
    /// Dil menyusunda göstərilən qısa kod.
    var shortCode: String {
        switch self {
        case .english: "EN"
        case .azerbaijani: "AZ"
        case .russian: "RU"
        case .turkish: "TR"
        }
    }
}

extension AppLanguage {
    /// Telefonun dili dəstəklənirsə o, deyilsə ingilis dili.
    static var deviceDefault: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? ""
        switch code {
        case "az": return .azerbaijani
        case "ru": return .russian
        case "tr": return .turkish
        default: return .english
        }
    }
}
