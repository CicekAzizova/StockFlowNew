//
//  PaymentViewModel.swift
//  StockFlow
//
//  Created by Cicek on 24.11.26.
//

import Foundation

/// Ödəniş ekranındakı seçimlər. Qarışıqda bir hissə nağd, qalanı kart olur.
enum SalePaymentKind: String, CaseIterable, Hashable {
    case cash, card, transfer, mixed
}

enum PaymentState {
    case ready
    case submitting
    case completed(CreateSaleResponse)
    case error(String)
}

@Observable
@MainActor
final class PaymentViewModel {

    private let salesStore: SalesStore
    private let productsStore: ProductsStore
    let cart: CartViewModel

    var kind: SalePaymentKind = .cash
    /// Nağd ödənişdə müştəridən alınan məbləğ.
    var receivedText = ""
    /// Qarışıq ödənişdə nağd hissə, qalanı kart sayılır.
    var cashPartText = ""

    private(set) var state: PaymentState = .ready

    init(salesStore: SalesStore, productsStore: ProductsStore, cart: CartViewModel) {
        self.salesStore = salesStore
        self.productsStore = productsStore
        self.cart = cart
    }

    // MARK: - Məbləğlər

    var total: Double { cart.total }

    /// Müştəridən alınan (yazılmayıbsa 0).
    var received: Double { Self.parse(receivedText) }

    /// Qaytarılacaq qalıq. Alınan məbləğ cəmdən azdırsa nil.
    var change: Double? {
        guard kind == .cash, received > 0, received >= total else { return nil }
        return Self.round(received - total)
    }

    /// Qarışıqda nağd hissə (cəmdən çox ola bilməz).
    var cashPart: Double { min(Self.parse(cashPartText), total) }

    /// Qarışıqda qalan hissə kartla ödənilir.
    var cardPart: Double { Self.round(total - cashPart) }

    /// Nağd düymələri: cəmdən yuxarı yuvarlaq məbləğlər.
    var quickAmounts: [Double] {
        let steps: [Double] = [1, 5, 10, 20, 50]
        var values: [Double] = []
        for step in steps {
            let value = (total / step).rounded(.up) * step
            if value > 0, value >= total, !values.contains(value) {
                values.append(value)
            }
        }
        return Array(values.prefix(4))
    }

    // MARK: - Yoxlama

    var canComplete: Bool {
        guard !cart.isEmpty, total > 0 else { return false }
        if case .submitting = state { return false }

        switch kind {
        case .cash:
            // Alınan məbləğ yazılmaya da bilər (dəqiq ödəniş).
            return receivedText.isEmpty || received >= total
        case .card, .transfer:
            return true
        case .mixed:
            return cashPart > 0 && cardPart > 0
        }
    }

    // MARK: - Satışı tamamla

    func complete() async {
        guard canComplete else { return }
        state = .submitting

        let items = cart.items.map {
            SaleItemRequest(productId: $0.product.id, quantity: $0.quantity)
        }
        let discount = cart.manualDiscountAmount

        let request = CreateCartSaleRequest(
            items: items,
            paymentMethod: kind == .mixed ? "cash" : kind.rawValue,
            payments: kind == .mixed
                ? [
                    SalePaymentRequest(method: "cash", amount: cashPart),
                    SalePaymentRequest(method: "card", amount: cardPart)
                  ]
                : nil,
            discount: discount > 0 ? discount : nil
        )

        do {
            let response = try await salesStore.createCartSale(request)
            await productsStore.refreshStock()
            state = .completed(response)
        } catch is CancellationError {
            state = .ready
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func dismissError() {
        state = .ready
    }

    // MARK: - Kömək

    private static func parse(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private static func round(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
