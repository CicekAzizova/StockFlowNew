//
//  AppPreferences.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

/// İstifadəçinin cihazda saxlanılan tətbiq seçimləri.
@Observable
final class AppPreferences {

    private let defaults: UserDefaults

    private enum Key {
        static let colorScheme = "app_color_scheme"
        static let lowStockAlerts = "low_stock_alerts_enabled"
    }

    /// `UserDefaults`-da saxlanılan rejim (sətir əvəzinə enum).
    private enum StoredScheme: String {
        case light
        case dark

        init(scheme: ColorScheme) {
            self = scheme == .dark ? .dark : .light
        }

        var scheme: ColorScheme {
            self == .dark ? .dark : .light
        }
    }

    /// `nil` olsa tətbiq sistemin rejimini izləyir.
    var colorSchemeOverride: ColorScheme? {
        didSet {
            let stored = colorSchemeOverride.map { StoredScheme(scheme: $0).rawValue }
            defaults.set(stored, forKey: Key.colorScheme)
        }
    }

    var lowStockAlertsEnabled: Bool {
        didSet { defaults.set(lowStockAlertsEnabled, forKey: Key.lowStockAlerts) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        colorSchemeOverride = defaults.string(forKey: Key.colorScheme)
            .flatMap(StoredScheme.init(rawValue:))?
            .scheme

        lowStockAlertsEnabled = defaults.object(forKey: Key.lowStockAlerts) as? Bool ?? true
    }
}
