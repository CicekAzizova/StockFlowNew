//
//  CatalogEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import Foundation

enum CatalogEndpoint: Endpoint {

    case categories

    var path: String { "/catalog/categories" }

    var method: HttpMethod { .get }

    // Kataloq ictimaidir, token lazım deyil.
    var requiresAuthentication: Bool { false }

    var httpBody: (any Encodable)? { nil }
}
