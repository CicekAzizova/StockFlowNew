//
//  TeamViewModel.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

@Observable
@MainActor
final class TeamViewModel {

    private let repository: SalesAssociateRepository

    var state: TeamViewState = .idle

    var searchText = ""

    init(repository: SalesAssociateRepository) {
        self.repository = repository
    }

    var filteredAssociates: [SalesAssociateResponse] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return salesAssociates }

        return salesAssociates.filter {
            "\($0.name) \($0.surname)".localizedStandardContains(query)
                || $0.email.localizedStandardContains(query)
                || $0.phone.contains(query)
        }
    }

    var salesAssociates: [SalesAssociateResponse] = []

    var salesAssociateCount: Int {
        salesAssociates.count
    }

    /// Hazırda onlayn olan satıcıların sayı (deaktivlər sayılmır).
    var onlineCount: Int {
        salesAssociates.filter { $0.isCurrentlyOnline && !$0.isDeactivated }.count
    }

    var totalSales: Double {
        salesAssociates.first?.totalSalesThisMonth ?? 0
    }

    var todayTotalSales: Double {
        salesAssociates.reduce(0) { $0 + $1.todaySales }
    }

    func loadSalesAssociates() async {
        let previousState = state
        if !state.isLoaded { state = .loading }

        do {
            salesAssociates = try await repository.getSalesAssociates()
            state = .loaded
        }
        catch is CancellationError {
            state = previousState
        }
        catch {
            state = .error(error.localizedDescription)
        }
    }

    func refresh() async {
        await loadSalesAssociates()
    }
}
