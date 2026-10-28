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
}
