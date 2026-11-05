//
//  SellerEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

enum SellerEndpoint: Endpoint {

    case addSeller(SellerRequest)
    case getSellers
    case editSeller(id: Int, request: UpdateSellerRequest)
    case delete(id: Int)
    case deactivate(id: Int)
    case activate(id: Int)

    var path: String {
        switch self {
        case .addSeller:
            "/users/sales-associate"
        case .delete(let id):
            "/users/\(id)"
        case .getSellers:
            "/users"
        case .editSeller(let id, _):
            "/users/sales-associate/\(id)"
        case .deactivate(let id):
            "/users/sales-associate/\(id)/deactivate"
        case .activate(let id):
            "/users/sales-associate/\(id)/activate"
        }
    }

    var requiresAuthentication: Bool {
        true
    }

    var method: HttpMethod {
        switch self {
        case .addSeller, .deactivate, .activate:
            .post
        case .delete:
            .delete
        case .getSellers:
            .get
        case .editSeller:
            .patch
        }
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .addSeller(let request):
            return request
        case .editSeller(_, let request):
            return request
        case .deactivate, .activate:
            // Backend POST sorğusunda JSON gözləyir, ona görə boş obyekt: {}
            return EmptyBody()
        case .delete, .getSellers:
            return nil
        }
    }
}

/// Gövdəsi olmayan POST sorğuları üçün `{}` kimi göndərilir.
private struct EmptyBody: Encodable {}
