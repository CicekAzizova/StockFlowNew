//
//  ReportsEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import Foundation

enum ReportsEndpoint: Endpoint {

    case salesReport(period: ReportPeriod, year: Int?, locationId: Int?)

    var path: String {
        "/reports/sales"
    }

    var method: HttpMethod {
        .get
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .salesReport(let period, let year, let locationId):
            var items = [URLQueryItem(name: "period", value: period.rawValue)]
            if let year {
                items.append(URLQueryItem(name: "year", value: String(year)))
            }
            if let locationId {
                items.append(URLQueryItem(name: "location_id", value: String(locationId)))
            }
            return items
        }
    }
}
