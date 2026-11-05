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

    var body: some View {
        @Bindable var preferences = preferences
        @Bindable var languageManager = languageManager

        AppSectionView("Settings") {
            AppRowView(icon: "exclamationmark.triangle", tint: .orange, title: "Low Stock Alerts") {
                Toggle("Low Stock Alerts", isOn: $preferences.lowStockAlertsEnabled)
                    .labelsHidden()
                    .tint(.brandGreen)
            }

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
    }

    // MARK: - Bindings

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
