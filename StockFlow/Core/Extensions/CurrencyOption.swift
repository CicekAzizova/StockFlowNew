//
//  CurrencyOption.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

/// Seçilə bilən valyutalar (backend-dəki siyahı ilə eyni olmalıdır).
enum CurrencyOption: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case azn = "AZN"
    case tryLira = "TRY"
    case rub = "RUB"
    case gbp = "GBP"

    var id: String { rawValue }

    /// Kod və tətbiqin dilində ad, məsələn "USD · US Dollar".
    var displayName: String {
        let name = Locale.current.localizedString(forCurrencyCode: rawValue) ?? rawValue
        return "\(name)"
    }
}
