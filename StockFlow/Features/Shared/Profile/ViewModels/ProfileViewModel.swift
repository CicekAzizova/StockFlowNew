//
//  ProfileViewModel.swift
//  StockFlow
//
//  Created by Cicek on 25.09.26.
//

import Foundation
import UIKit

@MainActor
@Observable
final class ProfileViewModel {

    private let userRepository: UserRepository
    private let appStateManager: AppStateManager
    private let productsStore: ProductsStore
    private let salesStore: SalesStore
    private let storeRepository: StoreRepository
    private let locationRepository: LocationRepository
    var isUploadingAvatar = false

    /// Avatar xətası ekranın üstündə göstərilir (məs. şəkil oxuna bilmədi).
    var avatarError: String?
    
    init(userRepository: UserRepository,   appStateManager: AppStateManager,
         productsStore: ProductsStore,
         salesStore: SalesStore,
         storeRepository: StoreRepository,
         locationRepository: LocationRepository) {
        self.userRepository = userRepository
        self.appStateManager = appStateManager
        self.productsStore = productsStore
        self.salesStore = salesStore
        self.storeRepository = storeRepository
        self.locationRepository = locationRepository
    }
    
    // MARK: - Locations

    var locations: [StoreLocation] = []
    var activeLocationId: Int? = ActiveLocationStore.id

    /// Seçilmiş məkan. Heç nə seçilməyibsə əsas məkan.
    var activeLocation: StoreLocation? {
        locations.first { $0.id == activeLocationId } ?? locations.first { $0.isMain }
    }

    func loadLocations() async {
        guard user?.role == .owner else { return }
        locations = (try? await locationRepository.getLocations()) ?? locations

        // Seçilmiş məkan silinibsə əsas məkana qayıdırıq.
        if let id = activeLocationId, !locations.contains(where: { $0.id == id }) {
            selectLocation(nil)
        }
    }

    /// nil = əsas məkan.
    func selectLocation(_ location: StoreLocation?) {
        let id = (location?.isMain == true) ? nil : location?.id
        guard id != activeLocationId else { return }
        ActiveLocationStore.id = id
        ActiveLocationStore.name = id == nil ? nil : location?.name
        activeLocationId = id

        // Qalıq məkandan asılıdır, köhnə siyahılar yenilənməlidir.
        productsStore.reset()
        salesStore.reset()
        NotificationCenter.default.post(name: .activeLocationChanged, object: nil)
    }
    
    // MARK: - Stats

    var productsCount: Int {
        productsStore.productsCount
    }

    var ordersCount: Int {
        salesStore.salesSummary?.totalOrders ?? 0
    }
    
    var user: User? {
        appStateManager.user
    }
    
    /// Panel ekranı hələ açılmayıbsa, statistikanı özümüz yükləyirik.
    func loadStats() async {
        if salesStore.salesSummary == nil {
            try? await salesStore.loadSalesSummary()
        }
        if salesStore.salesSummary != nil, productsStore.productsCount == 0 {
            try? await productsStore.loadProducts()
        }
    }

    // MARK: - Avatar (owner və satıcı)

    func setAvatar(_ image: UIImage) async {
        avatarError = nil
        guard let jpeg = image.resized(maxDimension: 800).jpegData(compressionQuality: 0.8) else {
            avatarError = String(localized: "Could not read the selected image.")
            return
        }
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }

        do {
            apply(try await userRepository.uploadAvatar(jpeg))
        } catch {
            avatarError = error.localizedDescription
        }
    }

    func removeAvatar() async {
        avatarError = nil
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }

        do {
            apply(try await userRepository.deleteAvatar())
        } catch {
            avatarError = error.localizedDescription
        }
    }

    // MARK: - Owner əməliyyatları (uğurlu olsa nil, əks halda xəta mətni)

    func updateProfile(name: String, surname: String, phone: String) async -> String? {
        do {
            let user = try await userRepository.updateProfile(
                name: name.trimmed,
                surname: surname.trimmed,
                phone: phone.trimmed
            )
            apply(user)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    func updateCurrency(_ code: String) async -> String? {
        guard var user = appStateManager.user, user.currency != code else { return nil }
        do {
            let store = try await storeRepository.updateCurrency(code)
            user.currency = store.currency
            apply(user)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    func updateCategories(_ codes: [String]) async -> String? {
        guard var user = appStateManager.user else { return nil }
        do {
            let store = try await storeRepository.updateStore(UpdateStoreRequest(mainCategories: codes))
            user.mainCategories = store.mainCategories
            apply(user)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func changePassword(current: String, new: String) async -> String? {
        do {
            try await userRepository.changePassword(current: current, new: new)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    /// Hesab silinəndə tokenlər təmizlənir və istifadəçi giriş ekranına qayıdır.
    func deleteAccount(password: String) async -> String? {
        do {
            try await userRepository.deleteAccount(password: password)
            appStateManager.logout()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func apply(_ user: User) {
        appStateManager.user = user
    }
}
