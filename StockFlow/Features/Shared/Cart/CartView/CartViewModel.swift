//
//  CartViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

/// Səbətdəki bir məhsul.
struct CartItem: Identifiable {
    let product: ProductsResponse
    var quantity: Int

    var id: Int { product.id }

    /// Məhsulun öz endirimi nəzərə alınmadan.
    var fullPrice: Double { Self.round(product.price * Double(quantity)) }

    /// Məhsulun öz endirimi ilə (serverin hesabı ilə eyni).
    var lineTotal: Double { Self.round(product.discountedPrice * Double(quantity)) }

    var canIncrement: Bool { quantity < product.quantity }

    private static func round(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}

@Observable
@MainActor
final class CartViewModel {

    private(set) var items: [CartItem] = []

    /// Kassirin əl ilə yazdığı ümumi endirim (manatla).
    /// Kassirin yazdığı endirim: manat və ya faiz.
    enum ManualDiscount: Equatable {
        case none
        case amount(Double)
        case percent(Double)
    }

    private(set) var manualDiscount: ManualDiscount = .none

    // MARK: - Məhsullar

    /// Məhsulu səbətə atır. Artıq varsa sayını artırır (qalıqdan çox olmaz).
    func add(_ product: ProductsResponse) {
        guard product.isForSale, product.quantity > 0 else { return }

        if let index = items.firstIndex(where: { $0.id == product.id }) {
            guard items[index].canIncrement else { return }
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }

    func increment(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              items[index].canIncrement else { return }
        items[index].quantity += 1
    }

    /// Sayı 1-dirsə məhsul səbətdən çıxır.
    func decrement(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func clear() {
        items = []
        manualDiscount = .none
    }

    func contains(_ product: ProductsResponse) -> Bool {
        items.contains { $0.id == product.id }
    }

    // MARK: - Cəmlər

    var isEmpty: Bool { items.isEmpty }

    /// Səbətdəki ümumi ədəd sayı.
    var itemsCount: Int { items.reduce(0) { $0 + $1.quantity } }

    /// Heç bir endirimsiz cəm ("Ara cəm").
    var subtotal: Double { round(items.reduce(0) { $0 + $1.fullPrice }) }

    /// Məhsulların öz endirimlərinin cəmi.
    var productDiscount: Double {
        round(subtotal - discountedSubtotal)
    }

    /// Məhsul endirimlərindən sonrakı cəm.
    var discountedSubtotal: Double {
        round(items.reduce(0) { $0 + $1.lineTotal })
    }

    /// Kassirin endirimi manatla (faiz olsa, cəmə görə hesablanır, cəmdən çox olmaz).
    var manualDiscountAmount: Double {
        switch manualDiscount {
        case .none:
            return 0
        case .amount(let value):
            return round(min(value, discountedSubtotal))
        case .percent(let value):
            return round(discountedSubtotal * value / 100)
        }
    }

    /// Bütün endirimlərin cəmi (dizayndakı "Endirim" sətri).
    var totalDiscount: Double { round(productDiscount + manualDiscountAmount) }

    /// Ödəniləcək yekun məbləğ.
    var total: Double { round(max(discountedSubtotal - manualDiscountAmount, 0)) }

    // MARK: - Əl ilə endirim

    /// Endirim 0-dan az və məhsul endirimlərindən sonrakı cəmdən çox ola bilməz.
    func setManualDiscount(_ discount: ManualDiscount) {
        switch discount {
        case .none:
            manualDiscount = .none
        case .amount(let value):
            manualDiscount = value > 0 ? .amount(value) : .none
        case .percent(let value):
            let clamped = min(value, 100)
            manualDiscount = clamped > 0 ? .percent(clamped) : .none
        }
    }

    private func round(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
