//
//  TransferEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

enum TransferEndpoint: Endpoint {

    case create(CreateTransferRequest)

    var path: String { "/transfers" }

    var method: HttpMethod { .post }

    var httpBody: (any Encodable)? {
        switch self {
        case .create(let request):
            request
        }
    }
}
