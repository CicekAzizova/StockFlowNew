//
//  TransferStockViewModel.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

@MainActor
@Observable
final class TransferStockViewModel {

    private let transferRepository: TransferRepository
    private let locationRepository: LocationRepository

    let product: ProductsResponse

    var locations: [StoreLocation] = []
    var fromLocationId: Int?
    var toLocationId: Int?
    var quantity = ""

    var isSaving = false
    var errorMessage: String?

    init(
        transferRepository: TransferRepository,
        locationRepository: LocationRepository,
        product: ProductsResponse
    ) {
        self.transferRepository = transferRepository
        self.locationRepository = locationRepository
        self.product = product
    }

    // MARK: - Məlumat

    func load() async {
        locations = (try? await locationRepository.getLocations()) ?? []

        // Mənbə: ən çox qalığı olan məkan. Təyinat: ondan fərqli ilk məkan (əsas məkan öndədir).
        let richest = product.stocks.max { $0.quantity < $1.quantity }?.locationId
        fromLocationId = richest ?? locations.first?.id
        toLocationId = locations.first { $0.id != fromLocationId }?.id
    }

    /// Seçilmiş mənbə məkanda bu məhsulun qalığı.
    var available: Int {
        product.stocks.first { $0.locationId == fromLocationId }?.quantity ?? 0
    }

    private var amount: Int? {
        Int(quantity.trimmed)
    }

    // MARK: - Göndərmə

    /// Uğurlu olsa true qaytarır.
    func transfer() async -> Bool {
        errorMessage = nil

        guard let from = fromLocationId, let to = toLocationId, from != to else {
            errorMessage = String(localized: "Choose two different locations.")
            return false
        }
        guard let amount, amount > 0 else {
            errorMessage = String(localized: "Enter a valid quantity.")
            return false
        }
        guard amount <= available else {
            errorMessage = String(localized: "Not enough stock at the source location.")
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await transferRepository.createTransfer(
                CreateTransferRequest(
                    fromLocationId: from,
                    toLocationId: to,
                    items: [TransferItemRequest(productId: product.id, quantity: amount)]
                )
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
