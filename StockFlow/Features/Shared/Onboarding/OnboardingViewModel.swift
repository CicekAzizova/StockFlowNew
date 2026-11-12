//
//  OnboardingViewModel.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

@MainActor
@Observable
final class OnboardingViewModel {

    enum Step: Int, CaseIterable {
        case store
        case categories
    }

    var step: Step = .store

    // Addım 1: mağaza
    var storeName = ""
    var phone = ""
    var city = ""
    var countryCode: String
    var currency: CurrencyOption

    // Addım 2: kateqoriyalar
    var selectedCategories: [String] = []

    var isSaving = false
    var nameError: String?
    var errorMessage: String?

    private let storeRepository: StoreRepository
    private let appStateManager: AppStateManager

    init(storeRepository: StoreRepository, appStateManager: AppStateManager) {
        self.storeRepository = storeRepository
        self.appStateManager = appStateManager
        let region = Locale.current.region?.identifier ?? "US"
        self.countryCode = region
        self.currency = CountryOption.defaultCurrency(for: region)
        self.phone = appStateManager.user?.phone ?? ""
    }

    /// Ölkə dəyişəndə valyuta da ona uyğun dəyişir (istifadəçi sonra əl ilə dəyişə bilər).
    func countryChanged() {
        currency = CountryOption.defaultCurrency(for: countryCode)
    }


    func back() {
        errorMessage = nil
        step = .store
    }

    /// Addım 1: mağaza məlumatını saxlayır, uğurlu olsa 2-ci addıma keçir.
    func continueFromStore() async {
        nameError = nil
        errorMessage = nil
        let name = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            nameError = "Store name is required."
            return
        }
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)

        isSaving = true
        defer { isSaving = false }
        do {
            let store = try await storeRepository.updateStore(
                UpdateStoreRequest(
                    name: name,
                    phone: trimmedPhone.isEmpty ? nil : trimmedPhone,
                    currency: currency.rawValue,
                    country: countryCode,
                    city: trimmedCity,
                    timezone: TimeZone.current.identifier
                )
            )
            apply(store)
            step = .categories
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Addım 2: kateqoriyaları saxlayır və qeydiyyatı bitmiş sayır. Sonra AppRouter özü Panelə keçir.
    func finish() async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            let store = try await storeRepository.updateStore(
                UpdateStoreRequest(
                    mainCategories: selectedCategories.isEmpty ? ["other"] : selectedCategories,
                    onboardingCompleted: true
                )
            )
            apply(store)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func apply(_ store: StoreDetailsResponse) {
        guard var user = appStateManager.user else { return }
        user.storeName = store.name
        user.currency = store.currency
        user.mainCategories = store.mainCategories
        user.onboardingCompleted = store.onboardingCompleted
        appStateManager.user = user
    }
}
