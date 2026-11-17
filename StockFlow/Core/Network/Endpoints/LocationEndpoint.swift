//
//  LocationEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

enum LocationEndpoint: Endpoint {

    case list
    case create(CreateLocationRequest)
    case update(id: Int, request: UpdateLocationRequest)
    case delete(id: Int)

    var path: String {
        switch self {
        case .list, .create:
            "/locations"
        case .update(let id, _), .delete(let id):
            "/locations/\(id)"
        }
    }

    var method: HttpMethod {
        switch self {
        case .list:
            .get
        case .create:
            .post
        case .update:
            .patch
        case .delete:
            .delete
        }
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .list, .delete:
            nil
        case .create(let request):
            request
        case .update(_, let request):
            request
        }
    }
}
