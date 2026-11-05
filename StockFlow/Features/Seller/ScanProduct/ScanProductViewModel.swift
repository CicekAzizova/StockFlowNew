//
//  ScanProductViewModel.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//

import Foundation

@Observable
@MainActor
final class ScanProductViewModel {
    
    private let productRepository: ProductRepository
    private let salesStore: SalesStore
    private let productsStore: ProductsStore
    
    
    var state: ScanProductState = .scanning
    var quantity = 1
    var isSubmitting = false
    var submitError: String?
    
    init(
        productRepository: ProductRepository,
        salesStore: SalesStore,
        productsStore: ProductsStore
    ) {
        self.productRepository = productRepository
        self.salesStore = salesStore
        self.productsStore = productsStore
    }
    
    // MARK: - Scan
    
    func handleScanned(code: String) async {
        guard case .scanning = state else { return }
        
        let sku = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sku.isEmpty else { return }
        
        state = .loading
        
        do {
            let product = try await productRepository.getProduct(bySku: sku)
            quantity = 1
            submitError = nil
            state = .found(product)
        } catch is CancellationError {
            state = .scanning
        } catch NetworkError.serverError(let statusCode, _) where statusCode == 404 {
            state = .notFound(sku)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func rescan() {
        quantity = 1
        submitError = nil
        state = .scanning
    }
    
    // MARK: - Quantity
    
    var maxQuantity: Int {
        if case .found(let product) = state { return product.quantity }
        return 0
    }
    
    var canIncrement: Bool { quantity < maxQuantity }
    var canDecrement: Bool { quantity > 1 }
    
    func increment() {
        guard canIncrement else { return }
        quantity += 1
    }
    
    func decrement() {
        guard canDecrement else { return }
        quantity -= 1
    }
    
    var totalPrice: Double {
        guard case .found(let product) = state else { return 0 }
        return product.discountedPrice * Double(quantity)
    }
    
    // MARK: - Sale
    
    func completeSale() async {
        guard case .found(let product) = state, !isSubmitting else { return }
        
        isSubmitting = true
        submitError = nil
        defer { isSubmitting = false }
        
        do {
            let response = try await salesStore.createSale(
                productId: product.id,
                quantity: quantity
            )
            state = .saleCompleted(total: response.totalPrice)
            await productsStore.refreshStock()
        } catch is CancellationError {
            return
        } catch {
            submitError = error.localizedDescription
        }
    }
}
