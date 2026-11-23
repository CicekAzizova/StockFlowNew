//
//  ReportRepository.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

protocol ReportRepository {
    func getSalesReport(period: ReportPeriod, year: Int?, locationId: Int?) async throws -> SalesReport
}

final class DefaultReportRepository: ReportRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getSalesReport(period: ReportPeriod, year: Int?, locationId: Int?) async throws -> SalesReport {
        try await networkService.request(
            ReportsEndpoint.salesReport(period: period, year: year, locationId: locationId)
        )
    }
}
