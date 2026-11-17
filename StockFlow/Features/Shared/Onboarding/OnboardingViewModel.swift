//
//  OnboardingViewModel.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {

    enum Step: Int, CaseIterable {
        case store
        case categories
        case locations
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
    var selectedSubcategories: [String] = []
    
    var locations: [StoreLocation] = []
    /// Qeydiyyat bitəndə server cavabı. İstifadəçi "Go to dashboard" basanda tətbiq buna keçir.
    var finishedStore: StoreDetailsResponse?
    
    /// Hələ serverə yazılmamış öz kateqoriyalar (kodu serverdə yaranır).
    var customDrafts: [CustomDraft] = []

    struct CustomDraft: Identifiable, Hashable {
        let id = UUID()
        let main: String
        let name: String
    }

    var userName: String {
        appStateManager.user?.name ?? ""
    }
    
    var isSaving = false
    var nameError: String?
    var errorMessage: String?

    private let storeRepository: StoreRepository
    private let locationRepository: LocationRepository
    private let appStateManager: AppStateManager

    init(
        storeRepository: StoreRepository,
        locationRepository: LocationRepository,
        appStateManager: AppStateManager
    ) {
        self.storeRepository = storeRepository
        self.locationRepository = locationRepository
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
        switch step {
        case .locations: step = .categories
        case .categories: step = .store
        case .store: break
        }
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
                    mainCategories: selectedCategories.isEmpty ? ["other"] : selectedCategories,
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
    
    /// Yeni öz kateqoriyanı əlavə edir. Birinci seçilmiş əsas kateqoriyaya bağlanır. Boş və ya təkrar ad əlavə olunmur.
    func addCustomSubcategory(_ rawName: String) {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let main = selectedCategories.first ?? "other"
        let exists = customDrafts.contains {
            $0.main == main && $0.name.lowercased() == name.lowercased()
        }
        guard !exists else { return }
        customDrafts.append(CustomDraft(main: main, name: name))
    }

    func removeCustomSubcategory(_ draft: CustomDraft) {
        customDrafts.removeAll { $0.id == draft.id }
    }

    /// Addım 2: kateqoriyaları saxlayır və 3-cü addıma keçir.
    func continueFromCategories() async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            var subcategories = selectedSubcategories

            if !customDrafts.isEmpty {
                let saved = try await storeRepository.updateStore(
                    UpdateStoreRequest(
                        customSubcategories: customDrafts.map {
                            CustomSubcategoryInput(main: $0.main, name: $0.name)
                        }
                    )
                )
                let codes = saved.customSubcategories.map(\.code)
                subcategories += codes.filter { !subcategories.contains($0) }
            }

            let store = try await storeRepository.updateStore(
                UpdateStoreRequest(
                    mainCategories: selectedCategories.isEmpty ? ["other"] : selectedCategories,
                    subcategories: subcategories
                )
            )
            apply(store)
            await loadLocations()
            step = .locations
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Addım 3: qeydiyyatı bitmiş sayır. Sonra AppRouter özü Panelə keçir.
    func finish() async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            let store = try await storeRepository.updateStore(
                UpdateStoreRequest(onboardingCompleted: true)
            )
            finishedStore = store
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// "Hazırdır" ekranından panelə keçid: AppRouter bu anda wizard-dan çıxır.
    func enterApp() {
        if let store = finishedStore {
            apply(store)
        }
    }

    func loadLocations() async {
        do {
            locations = try await locationRepository.getLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Yeni məkan əlavə edir. Uğurlu olsa nil, olmasa xəta mətnini qaytarır.
    func addLocation(name: String, kind: LocationKind, address: String, makeMain: Bool) async -> String? {
        do {
            _ = try await locationRepository.createLocation(
                CreateLocationRequest(name: name, kind: kind, address: address, isMain: makeMain)
            )
            locations = try await locationRepository.getLocations()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    
    /// Əsas olmayan məkanı silir. Uğurlu olsa nil, olmasa xəta mətnini qaytarır.
    func deleteLocation(_ location: StoreLocation) async -> String? {
        do {
            try await locationRepository.deleteLocation(id: location.id)
            locations = try await locationRepository.getLocations()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    /// Məkanı əsas edir (köhnə əsas məkan avtomatik adi məkana çevrilir).
    func makeMainLocation(_ location: StoreLocation) async -> String? {
        do {
            _ = try await locationRepository.updateLocation(
                id: location.id,
                UpdateLocationRequest(isMain: true)
            )
            locations = try await locationRepository.getLocations()
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    private func apply(_ store: StoreDetailsResponse) {
        guard var user = appStateManager.user else { return }
        user.storeName = store.name
        user.currency = store.currency
        user.mainCategories = store.mainCategories
        user.subcategories = store.subcategories
        user.customSubcategories = store.customSubcategories
        user.onboardingCompleted = store.onboardingCompleted
        appStateManager.user = user
    }
}
