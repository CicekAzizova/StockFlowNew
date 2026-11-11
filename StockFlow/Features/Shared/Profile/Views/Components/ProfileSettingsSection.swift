//
//  ProfileSettingsSection.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

struct ProfileSettingsSection: View {

    @Environment(AppPreferences.self) private var preferences
    @Environment(AppLockManager.self) private var appLockManager
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.colorScheme) private var colorScheme
    
    let user: User
    let onCurrencyChange: (String) async -> String?

    @State private var pendingCurrency: CurrencyOption?
    @State private var currencyError: String?

    var body: some View {
        @Bindable var preferences = preferences
        @Bindable var languageManager = languageManager

        AppSectionView("Settings") {

            AppRowView(icon: "globe", tint: .purple, title: "Language") {
                Picker("Language", selection: $languageManager.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .labelsHidden()
                .fixedSize()
                .tint(Color.textSecondary)
            }
            
            if user.role == .owner {
                AppRowView(icon: "banknote", tint: .green, title: "Currency") {
                    Picker("Currency", selection: currencyBinding) {
                        ForEach(CurrencyOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                    .tint(Color.textSecondary)
                }
            }

            
            AppRowView(icon: "exclamationmark.triangle", tint: .orange, title: "Low Stock Alerts") {
                Toggle("Low Stock Alerts", isOn: $preferences.lowStockAlertsEnabled)
                    .labelsHidden()
                    .tint(.brandGreen)
            }
            
            AppRowView(icon: "moon", tint: .gray, title: "Dark Mode") {
                Toggle("Dark Mode", isOn: darkModeBinding)
                    .labelsHidden()
                    .tint(.brandGreen)
            }

            if appLockManager.canUseBiometrics {
                AppRowView(icon: "faceid", tint: .brandTeal, title: "Face ID") {
                    Toggle("Face ID", isOn: faceIDBinding)
                        .labelsHidden()
                        .tint(.brandGreen)
                }
            }
        }
        .confirmationDialog(
            "Change currency?",
            isPresented: Binding(
                get: { pendingCurrency != nil },
                set: { if !$0 { pendingCurrency = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Change") {
                guard let option = pendingCurrency else { return }
                pendingCurrency = nil
                Task { currencyError = await onCurrencyChange(option.rawValue) }
            }
            Button("Cancel", role: .cancel) { pendingCurrency = nil }
        } message: {
            Text("Existing amounts are not converted. Only the currency changes.")
        }
        .alert(
            "Could not change currency",
            isPresented: Binding(
                get: { currencyError != nil },
                set: { if !$0 { currencyError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(currencyError ?? "")
        }
    }

    // MARK: - Bindings
    
    /// Picker cari valyutanı göstərir. Dəyişəndə dərhal tətbiq olunmur, əvvəl təsdiq soruşulur.
    private var currencyBinding: Binding<CurrencyOption> {
        Binding {
            CurrencyOption(rawValue: user.currency ?? "USD") ?? .usd
        } set: { option in
            if option.rawValue != (user.currency ?? "USD") {
                pendingCurrency = option
            }
        }
    }

    /// Toggle cari görünən rejimi göstərir. Dəyişəndə seçim artıq sistemə yox, istifadəçiyə bağlı olur.
    private var darkModeBinding: Binding<Bool> {
        Binding {
            colorScheme == .dark
        } set: { isOn in
            preferences.colorSchemeOverride = isOn ? .dark : .light
        }
    }

    private var faceIDBinding: Binding<Bool> {
        Binding {
            appLockManager.isBiometricsEnabled
        } set: { isOn in
            if isOn {
                Task { await appLockManager.enableBiometrics() }
            } else {
                appLockManager.setBiometrics(false)
            }
        }
    }
}
