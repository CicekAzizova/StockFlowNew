//
//  SalesViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

enum SalesPeriod: Hashable {
    case today, week, month, custom
}

/// Bir günün satışları (siyahıda başlıqla göstərilir).
struct SalesDayGroup: Identifiable {
    let day: Date
    let sales: [SaleResponse]
    var id: Date { day }
}

/// Süzgəc menyusundakı bir seçim.
struct SalesSellerOption: Identifiable {
    let id: Int
    let name: String
}

@Observable
@MainActor
final class SalesViewModel {

    private let repository: SalesRepository
    private let sellerRepository: SellerRepository?
    private let pageSize = 20

    var period: SalesPeriod = .today
    var customFrom = Date.now
    var customTo = Date.now
    /// Yalnız owner üçün: nil = bütün satıcılar.
    var sellerId: Int?

    /// Cari istifadəçi (owner), menyuda ən yuxarıda göstərilir.
    var currentUserId: Int?
    var currentUserName = ""

    /// Süzgəc menyusu üçün: owner + komandanın bütün satıcıları.
    private(set) var sellers: [SalesSellerOption] = []

    private(set) var totals: SalesTotalsResponse?
    private(set) var sales: [SaleResponse] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?

    private var page = 1
    private var hasMore = true

    init(repository: SalesRepository, sellerRepository: SellerRepository? = nil) {
        self.repository = repository
        self.sellerRepository = sellerRepository
    }

    // MARK: - Dövr

    /// Seçilmiş dövrün ilk və son günü. Həftə = son 7 gün, ay = son 30 gün.
    private var range: (from: Date, to: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        switch period {
        case .today:
            return (today, today)
        case .week:
            return (calendar.date(byAdding: .day, value: -6, to: today) ?? today, today)
        case .month:
            return (calendar.date(byAdding: .day, value: -29, to: today) ?? today, today)
        case .custom:
            let first = calendar.startOfDay(for: min(customFrom, customTo))
            let last = calendar.startOfDay(for: max(customFrom, customTo))
            return (first, last)
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var rangeStrings: (from: String, to: String) {
        (Self.dayFormatter.string(from: range.from), Self.dayFormatter.string(from: range.to))
    }

    // MARK: - Yükləmə

    func load() async {
        isLoading = true
        errorMessage = nil
        page = 1
        hasMore = true

        let days = rangeStrings
        do {
            async let totalsTask = repository.getSalesTotals(
                from: days.from, to: days.to, sellerId: sellerId
            )
            async let pageTask = repository.getSalesInRange(
                from: days.from, to: days.to, sellerId: sellerId, page: 1, limit: pageSize
            )
            let (newTotals, firstPage) = try await (totalsTask, pageTask)
            totals = newTotals
            sales = firstPage.items
            hasMore = firstPage.hasNext
        } catch is CancellationError {
            // dövr dəyişdi, yeni sorğu gəlir
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoading, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        let days = rangeStrings
        do {
            let next = try await repository.getSalesInRange(
                from: days.from, to: days.to, sellerId: sellerId, page: page + 1, limit: pageSize
            )
            page += 1
            sales += next.items
            hasMore = next.hasNext
        } catch {
            // növbəti səhifə yüklənmədi, siyahı olduğu kimi qalır
        }
    }

    func loadSellers() async {
        guard let sellerRepository, let currentUserId else { return }
        do {
            let team = try await sellerRepository.getSellers()
            let others = team
                .map { SalesSellerOption(id: $0.id, name: "\($0.name) \($0.surname)") }
                .sorted { $0.name < $1.name }
            sellers = [SalesSellerOption(id: currentUserId, name: currentUserName)] + others
        } catch {
            // menyu boş qalır, siyahı yenə işləyir
        }
    }

    // MARK: - Qruplaşdırma və müqayisə

    /// Satışlar günlərə görə, yeni günlər yuxarıda.
    var groups: [SalesDayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sales) { calendar.startOfDay(for: $0.createdAt) }
        return grouped.keys.sorted(by: >).map { SalesDayGroup(day: $0, sales: grouped[$0] ?? []) }
    }

    /// Əvvəlki dövrə görə faiz fərqi. Əvvəl 0 idisə, nil qaytarır.
    func change(current: Double, previous: Double) -> Double? {
        guard previous > 0 else { return nil }
        return (current - previous) / previous * 100
    }

    var ordersChange: Double? {
        guard let totals else { return nil }
        return change(current: Double(totals.orders), previous: Double(totals.previous.orders))
    }
}
