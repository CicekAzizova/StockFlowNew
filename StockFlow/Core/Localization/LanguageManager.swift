//
//  LanguageManager.swift
//  StockFlow
//
//  Created by Cicek on 28.10.26.
//
import SwiftUI

@Observable
final class LanguageManager {
    
    private let defaults: UserDefaults
    private let storageKey = "app_language"
    
    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: storageKey)}
    }
    
    var locale: Locale {
        Locale(identifier: language.rawValue)
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let code = defaults.string(forKey: storageKey),
           let lang = AppLanguage(rawValue: code) {
            language = lang
        } else {
            language = .english
        }
    }
}



