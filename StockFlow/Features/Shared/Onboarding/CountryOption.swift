//
//  CountryOption.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

struct CountryOption: Identifiable, Hashable {
    let code: String            // ISO kodu: "AZ", "US"...
    var id: String { code }

    /// Ölkənin adı seçilmiş dildə (verilən locale-a görə).
    func name(in locale: Locale) -> String {
        locale.localizedString(forRegionCode: code) ?? code
    }

    /// Bütün ölkələr (iki hərfli ISO kodları).
    static let all: [CountryOption] = Locale.Region.isoRegions
        .map(\.identifier)
        .filter { $0.count == 2 }
        .map(CountryOption.init(code:))

    /// Ölkəyə uyğun default valyuta. Siyahıda olmayanlar üçün USD.
    static func defaultCurrency(for code: String) -> CurrencyOption {
        switch code {
        case "AZ": return .azn
        case "TR": return .tryLira
        case "RU": return .rub
        case "GB": return .gbp
        case "AT", "BE", "HR", "CY", "EE", "FI", "FR", "DE", "GR", "IE",
             "IT", "LV", "LT", "LU", "MT", "NL", "PT", "SK", "SI", "ES":
            return .eur
        default: return .usd
        }
    }
}
