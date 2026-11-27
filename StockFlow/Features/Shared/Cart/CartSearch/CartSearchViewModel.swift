//
//  CartSearchViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

enum CartSearchState {
    case idle
    case loading
    case loaded([ProductsResponse])
    case empty
    case error(String)
}

@Observable
@MainActor
final class CartSearchViewModel {

    private let productRepository: ProductRepository
    let cart: CartViewModel

    var query = ""
    private(set) var state: CartSearchState = .idle

    init(productRepository: ProductRepository, cart: CartViewModel) {
        self.productRepository = productRepository
        self.cart = cart
    }

    /// `.task(id: query)` ilə çağırılır: yazı dəyişəndə əvvəlki sorğu ləğv olur.
    func search() async {
        let text = query.trimmingCharacters(in: .whitespaces)

        // İstifadəçi yazmağa davam edə bilər, qısa gözləyirik.
        if !text.isEmpty {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
        }

        if case .loaded = state {} else { state = .loading }

        do {
            let page = try await productRepository.getProducts(
                page: 1,
                limit: 30,
                query: text.isEmpty ? nil : text,
                stock: nil,
                filter: ProductFilter(forSale: true, sort: .name)
            )
            state = page.items.isEmpty ? .empty : .loaded(page.items)
        } catch is CancellationError {
            return
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func add(_ product: ProductsResponse) {
        cart.add(product)
    }

    /// Məhsulun səbətdəki sayı (yoxdursa 0).
    func quantityInCart(_ product: ProductsResponse) -> Int {
        cart.items.first { $0.id == product.id }?.quantity ?? 0
    }
}
