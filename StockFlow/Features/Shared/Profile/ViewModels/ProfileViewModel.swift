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
    
    var isUploadingAvatar = false

    /// Avatar xətası ekranın üstündə göstərilir (məs. şəkil oxuna bilmədi).
    var avatarError: String?
    
    init(userRepository: UserRepository,   appStateManager: AppStateManager,
         productsStore: ProductsStore,
         salesStore: SalesStore,
         storeRepository: StoreRepository) {
        self.userRepository = userRepository
        self.appStateManager = appStateManager
        self.productsStore = productsStore
        self.salesStore = salesStore
        self.storeRepository = storeRepository
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
