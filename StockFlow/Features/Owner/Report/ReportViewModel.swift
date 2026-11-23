//
//  ReportViewModel.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

@Observable
@MainActor
final class ReportViewModel {

    private let repository: ReportRepository
    private let currentYear = Calendar.current.component(.year, from: .now)

    var period: ReportPeriod = .week
    /// İl görünüşündə seçilmiş təqvim ili.
    var year = Calendar.current.component(.year, from: .now)
    /// nil = bütün məkanlar.
    var locationId: Int?
    var report: SalesReport?
    var isLoading = false
    var errorMessage: String?

    init(repository: ReportRepository) {
        self.repository = repository
    }

    /// Seçilə bilən ən erkən il: ilk satışın ili.
    var firstYear: Int {
        min(report?.firstYear ?? currentYear, currentYear)
    }

    /// Seçim siyahısı: yeni illər yuxarıda.
    var availableYears: [Int] {
        Array((firstYear...currentYear).reversed())
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            report = try await repository.getSalesReport(
                period: period,
                year: period == .year ? year : nil,
                locationId: locationId
            )
        } catch is CancellationError {
            // ekran bağlandı və ya seçim dəyişdi, xəta göstərmirik
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Əvvəlki dövrə görə faiz fərqi. Əvvəl 0 idisə, nil qaytarır.
    func change(current: Double, previous: Double) -> Double? {
        guard previous > 0 else { return nil }
        return (current - previous) / previous * 100
    }
}
