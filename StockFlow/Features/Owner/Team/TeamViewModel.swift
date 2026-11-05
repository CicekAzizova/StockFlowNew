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

    private let repository: SellerRepository

    var state: TeamViewState = .idle

    var searchText = ""

    init(repository: SellerRepository) {
        self.repository = repository
    }

    var filteredSellers: [SellerResponse] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return sellers }

        return sellers.filter {
            "\($0.name) \($0.surname)".localizedStandardContains(query)
                || $0.email.localizedStandardContains(query)
                || $0.phone.contains(query)
        }
    }

    var sellers: [SellerResponse] = []

    var sellerCount: Int {
        sellers.count
    }

    /// Hazırda onlayn olan satıcıların sayı (deaktivlər sayılmır).
    var onlineCount: Int {
        sellers.filter { $0.isCurrentlyOnline && !$0.isDeactivated }.count
    }

    var totalSales: Double {
        sellers.first?.totalSalesThisMonth ?? 0
    }

    var todayTotalSales: Double {
        sellers.reduce(0) { $0 + $1.todaySales }
    }

    func loadSellers() async {
        let previousState = state
        if !state.isLoaded { state = .loading }

        do {
            sellers = try await repository.getSellers()
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
        await loadSellers()
    }
}
