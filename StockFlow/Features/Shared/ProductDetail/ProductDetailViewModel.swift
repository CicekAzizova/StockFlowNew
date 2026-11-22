//
//  ProductDetailViewModel.swift
//  StockFlow
//
//  Created by Cicek on 02.10.26.
//

import Foundation

enum ProductDetailTab: CaseIterable {
    case overview
    case stock
    case history
}

@Observable
@MainActor
final class ProductDetailViewModel {

    private let productStore: ProductsStore
    private let initialProduct: ProductsResponse
    private let historyPageSize = 20

    private var refreshedProduct: ProductsResponse?

    var product: ProductsResponse {
        productStore.product(withID: initialProduct.id) ?? refreshedProduct ?? initialProduct
    }

    var state: ProductDetailViewState = .idle
    var selectedTab: ProductDetailTab = .overview

    // MARK: - History

    private(set) var history: [StockMovement] = []
    private(set) var isLoadingHistory = false
    private(set) var historyError: String?
    private var historyPage = 1
    private var hasMoreHistory = false

    /// Mənim tərəfimdən xəta: "satışdadır" açarı və s. üçün.
    var actionError: String?

    init(productStore: ProductsStore, product: ProductsResponse) {
        self.productStore = productStore
        self.initialProduct = product
    }

    /// Transferdən sonra qalıqları təzələyir.
    func reload() async {
        refreshedProduct = await productStore.refreshProduct(sku: initialProduct.sku)
        if selectedTab == .history {
            await loadHistory()
        }
    }

    // MARK: - History

    /// Tarixçəni baştan yükləyir.
    func loadHistory() async {
        guard !isLoadingHistory else { return }
        isLoadingHistory = true
        historyError = nil
        defer { isLoadingHistory = false }

        do {
            let response = try await productStore.loadProductHistory(
                id: product.id, page: 1, limit: historyPageSize
            )
            history = response.items
            historyPage = response.page
            hasMoreHistory = response.hasNext
        } catch is CancellationError {
            return
        } catch {
            historyError = error.localizedDescription
        }
    }

    func loadHistoryIfNeeded() async {
        guard history.isEmpty, historyError == nil else { return }
        await loadHistory()
    }

    func loadMoreHistory() async {
        guard hasMoreHistory, !isLoadingHistory else { return }
        isLoadingHistory = true
        defer { isLoadingHistory = false }

        do {
            let response = try await productStore.loadProductHistory(
                id: product.id, page: historyPage + 1, limit: historyPageSize
            )
            let existing = Set(history.map(\.id))
            history.append(contentsOf: response.items.filter { !existing.contains($0.id) })
            historyPage = response.page
            hasMoreHistory = response.hasNext
        } catch is CancellationError {
            return
        } catch {
            historyError = error.localizedDescription
        }
    }

    // MARK: - For sale

    func setForSale(_ value: Bool) async {
        actionError = nil
        do {
            refreshedProduct = try await productStore.setForSale(id: product.id, forSale: value)
        } catch is CancellationError {
            return
        } catch {
            actionError = error.localizedDescription
        }
    }
    
    var isRestocking = false
    var restockError: String?

    /// Seçili mağazanın qalığına ədəd əlavə edir. Uğurlu olsa true qaytarır.
    func restock(quantity: Int, locationId: Int?) async -> Bool {
        guard !isRestocking else { return false }

        isRestocking = true
        restockError = nil
        defer { isRestocking = false }

        do {
            _ = try await productStore.restockProduct(id: product.id, quantity: quantity, locationId: locationId)
            if selectedTab == .history { await loadHistory() }
            return true
        } catch is CancellationError {
            return false
        } catch {
            restockError = error.localizedDescription
            return false
        }
    }

    // MARK: - Delete

    func deleteProduct() async {
        state = .deleting
        do {
            try await productStore.deleteProduct(id: product.id)
            state = .deleted
        }
        catch {
            state = .error(error.localizedDescription)
        }
    }
}
