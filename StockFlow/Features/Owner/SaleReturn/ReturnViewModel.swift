//
//  ReturnViewModel.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import Foundation

enum ReturnState {
    case editing
    case submitting
    case completed(SaleReturnResponse)
    case error(String)
}

@Observable
@MainActor
final class ReturnViewModel {

    private let repository: SalesRepository
    let sale: SaleResponse
    private let productsStore: ProductsStore?

    /// Sətir id-si → qaytarılacaq ədəd.
    private(set) var quantities: [Int: Int] = [:]
    var reason: ReturnReason = .damaged {
        didSet {
            // Zədəli mal rəfə qayıtmır.
            restock = reason != .damaged
        }
    }
    var restock = false
    /// Pul hansı üsulla qaytarılır. Standart olaraq satışın ödəniş üsulu.
    var refundMethod: PaymentMethod
    
    private(set) var state: ReturnState = .editing

    init(repository: SalesRepository, sale: SaleResponse, productsStore: ProductsStore? = nil) {
        self.repository = repository
        self.sale = sale
        self.productsStore = productsStore
        // Qarışıq ödənişdə kassir özü seçsin, standart nağddır.
        // Kartla qaytarma yoxdur: nağd və ya köçürmə seçilir.
        self.refundMethod = sale.paymentMethod == .transfer ? .transfer : .cash
    }

    // MARK: - Sətirlər

    /// Yalnız hələ qaytarılmamış ədədi qalan sətirlər.
    var items: [SaleItemResponse] {
        (sale.items ?? []).filter { $0.returnableQuantity > 0 }
    }

    func quantity(for item: SaleItemResponse) -> Int {
        quantities[item.id] ?? 0
    }

    func isSelected(_ item: SaleItemResponse) -> Bool {
        quantity(for: item) > 0
    }

    func toggle(_ item: SaleItemResponse) {
        quantities[item.id] = isSelected(item) ? 0 : item.returnableQuantity
    }

    func increment(_ item: SaleItemResponse) {
        let next = quantity(for: item) + 1
        guard next <= item.returnableQuantity else { return }
        quantities[item.id] = next
    }

    func decrement(_ item: SaleItemResponse) {
        let next = quantity(for: item) - 1
        quantities[item.id] = max(next, 0)
    }

    func selectAll() {
        for item in items {
            quantities[item.id] = item.returnableQuantity
        }
    }

    // MARK: - Məbləğ

    /// Təxmini geri ödəniş. Dəqiq məbləği server hesablayır.
    var total: Double {
        let sum = items.reduce(0.0) { result, item in
            guard item.quantity > 0 else { return result }
            let unit = item.lineTotal / Double(item.quantity)
            return result + unit * Double(quantity(for: item))
        }
        return (sum * 100).rounded() / 100
    }

    var canSubmit: Bool {
        if case .submitting = state { return false }
        return quantities.values.contains { $0 > 0 }
    }

    // MARK: - Göndərmə

    func submit() async {
        guard canSubmit else { return }
        state = .submitting

        let selected = items.compactMap { item -> ReturnItemRequest? in
            let quantity = quantity(for: item)
            guard quantity > 0 else { return nil }
            return ReturnItemRequest(saleItemId: item.id, quantity: quantity)
        }

        do {
            let response = try await repository.createReturn(
                saleId: sale.id,
                request: CreateReturnRequest(
                    items: selected,
                    reason: reason.rawValue,
                    refundMethod: refundMethod.rawValue,
                    restock: restock
                )
            )
            // Qalıq dəyişdi: məhsul siyahısı köhnə rəqəmi göstərməsin.
            await productsStore?.refreshStock()
            state = .completed(response)
        } catch is CancellationError {
            state = .editing
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func dismissError() {
        state = .editing
    }
}
