//
//  SalesAssociateDetailViewModel.swift
//  StockFlow
//
//  Created by Cicek on 14.10.26.
//

import Foundation

@Observable
@MainActor
final class SalesAssociateDetailViewModel {

    private let repository: SalesAssociateRepository
    private let salesRepository: SalesRepository
    private let pageSize = 10

    private(set) var associate: SalesAssociateResponse
    

    var state: SalesAssociateDetailViewState = .idle

    var salesState: AssociateSalesState = .idle
    var loadMoreError: String?
    private(set) var sales: [SaleResponse] = []
    private(set) var salesCount = 0
    private var currentPage = 0
    private var hasNext = false
    private var isLoadingMore = false

    init(
        repository: SalesAssociateRepository,
        salesRepository: SalesRepository,
        associate: SalesAssociateResponse
    ) {
        self.repository = repository
        self.salesRepository = salesRepository
        self.associate = associate
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
            .getSalesAssociates()
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

    func deleteSalesAssociate() async {
        state = .deleting
        do {
            try await repository.deleteSalesAssociate(id: associate.id)
            state = .deleted
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
