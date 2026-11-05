//
//  SellerDetailViewModel.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

import Foundation

@Observable
@MainActor
final class SellerDetailViewModel {

    private let repository: SellerRepository
    private let salesRepository: SalesRepository
    private let pageSize = 10

    private(set) var associate: SellerResponse

    var state: SellerDetailViewState = .idle

    /// Deaktiv/aktiv etmə zamanı true olur.
    private(set) var isChangingStatus = false
    var statusError: String?

    var salesState: AssociateSalesState = .idle
    var loadMoreError: String?
    private(set) var sales: [SaleResponse] = []
    private(set) var salesCount = 0
    private var currentPage = 0
    private var hasNext = false
    private var isLoadingMore = false

    init(
        repository: SellerRepository,
        salesRepository: SalesRepository,
        associate: SellerResponse
    ) {
        self.repository = repository
        self.salesRepository = salesRepository
        self.associate = associate
    }

    var memberSince: String? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()

        guard let date = withFraction.date(from: associate.createdAt)
            ?? plain.date(from: associate.createdAt) else { return nil }

        return date.formatted(.dateTime.day().month(.wide).year())
    }

    // MARK: - Sales

    func loadSalesIfNeeded() async {
        guard !salesState.isLoaded else { return }
        await loadSales()
    }

    func loadSales() async {
        let previousState = salesState
        if !salesState.isLoaded { salesState = .loading }

        do {
            let response = try await salesRepository.getSales(
                sellerId: associate.id,
                page: 1,
                limit: pageSize
            )
            sales = response.items
            salesCount = response.total
            currentPage = response.page
            hasNext = response.hasNext
            salesState = .loaded
        } catch is CancellationError {
            salesState = previousState
        } catch {
            salesState = .error(error.localizedDescription)
        }
    }

    func reloadAssociate() async {
        guard let updated = try? await repository
            .getSellers()
            .first(where: { $0.id == associate.id })
        else { return }
        associate = updated
    }

    func refresh() async {
        await reloadAssociate()
        await loadSales()
    }

    func loadMoreSales() async {
        guard hasNext, !isLoadingMore else { return }
        isLoadingMore = true
        loadMoreError = nil
        defer { isLoadingMore = false }

        do {
            let response = try await salesRepository.getSales(
                sellerId: associate.id,
                page: currentPage + 1,
                limit: pageSize
            )
            sales.append(contentsOf: response.items)
            currentPage = response.page
            hasNext = response.hasNext
        } catch is CancellationError {
            return
        } catch {
            loadMoreError = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteSeller() async {
        state = .deleting
        do {
            try await repository.deleteSeller(id: associate.id)
            state = .deleted
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Deactivate / activate

    func deactivate() async {
        await changeStatus { try await repository.deactivateSeller(id: associate.id) }
    }

    func activate() async {
        await changeStatus { try await repository.activateSeller(id: associate.id) }
    }

    private func changeStatus(
        _ action: () async throws -> SellerResponse
    ) async {
        guard !isChangingStatus else { return }
        isChangingStatus = true
        statusError = nil
        defer { isChangingStatus = false }

        do {
            associate = try await action()
        } catch is CancellationError {
            return
        } catch {
            statusError = error.localizedDescription
        }
    }
}
