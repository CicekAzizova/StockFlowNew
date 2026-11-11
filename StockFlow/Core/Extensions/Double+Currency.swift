//
//  Double+Currency.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//
import Foundation

/// Valyutanı saxlayan müşahidə olunan obyekt.
/// SwiftUI `asCurrency` işlədən ekranları valyuta dəyişəndə özü yeniləyir.
@Observable
final class CurrencyState {
    static let shared = CurrencyState()
    var code = "USD"
}

/// Tətbiqin valyutası. Mağazanın valyutasından təyin olunur.
enum AppCurrency {
    static var code: String {
        get { CurrencyState.shared.code }
        set { CurrencyState.shared.code = newValue }
    }
}

extension Double {
    var asCurrency: String {
        formatted(.currency(code: AppCurrency.code))
    }

    var asCompactCurrency: String {
        formatted(
            .currency(code: AppCurrency.code)
                .notation(.compactName)
                .precision(.fractionLength(0...1))
        )
    }
}
