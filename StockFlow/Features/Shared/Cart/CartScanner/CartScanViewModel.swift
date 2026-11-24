//
//  CartScanViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

@Observable
@MainActor
final class CartScanViewModel {

    enum Feedback {
        case added(product: ProductsResponse, quantity: Int)
        case limitReached(name: String)
        case outOfStock(name: String)
        case notForSale(name: String)
        case notFound(code: String)
        case error(String)
    }

    private let productRepository: ProductRepository
    let cart: CartViewModel

    private(set) var feedback: Feedback?
    /// Hər yeni mesajda artır, görünüşdə mesajı avtomatik gizlətmək üçün işlədilir.
    private(set) var feedbackId = 0

    private var lastCode: String?
    private var lastScanAt = Date.distantPast
    private var isLookingUp = false

    init(productRepository: ProductRepository, cart: CartViewModel) {
        self.productRepository = productRepository
        self.cart = cart
    }

    func handleScanned(code: String) async {
        let sku = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sku.isEmpty, !isLookingUp else { return }

        // Eyni barkod kameranın qarşısında qalanda təkrar sayılmasın.
        if sku == lastCode, Date.now.timeIntervalSince(lastScanAt) < 2 { return }
        lastCode = sku
        lastScanAt = .now

        isLookingUp = true
        defer { isLookingUp = false }

        do {
            let product = try await productRepository.getProduct(bySku: sku)
            add(product)
        } catch is CancellationError {
            return
        } catch NetworkError.serverError(let statusCode, _) where statusCode == 404 {
            show(.notFound(code: sku))
        } catch {
            show(.error(error.localizedDescription))
        }
    }

    func clearFeedback() {
        feedback = nil
    }

    private func add(_ product: ProductsResponse) {
        guard product.isForSale else { return show(.notForSale(name: product.name)) }
        guard product.quantity > 0 else { return show(.outOfStock(name: product.name)) }

        let before = quantityInCart(product)
        cart.add(product)
        let after = quantityInCart(product)

        if after > before {
            show(.added(product: product, quantity: after))
        } else {
            show(.limitReached(name: product.name))
        }
    }

    private func quantityInCart(_ product: ProductsResponse) -> Int {
        cart.items.first { $0.id == product.id }?.quantity ?? 0
    }

    private func show(_ newFeedback: Feedback) {
        feedback = newFeedback
        feedbackId += 1
    }
}
