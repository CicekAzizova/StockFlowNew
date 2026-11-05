//
//  SalesAssociateEndpoint.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

enum SalesAssociateEndpoint: Endpoint {

    case addSalesAssociate(SalesAssociateRequest)
    case getSalesAssociates
    case editSalesAssociate(id: Int, request: UpdateSalesAssociateRequest)
    case delete(id: Int)
    case deactivate(id: Int)
    case activate(id: Int)

    var path: String {
        switch self {
        case .addSalesAssociate:
            "/users/sales-associate"
        case .delete(let id):
            "/users/\(id)"
        case .getSalesAssociates:
            "/users"
        case .editSalesAssociate(let id, _):
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
        case .addSalesAssociate, .deactivate, .activate:
            .post
        case .delete:
            .delete
        case .getSalesAssociates:
            .get
        case .editSalesAssociate:
            .patch
        }
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .addSalesAssociate(let request):
            return request
        case .editSalesAssociate(_, let request):
            return request
        case .deactivate, .activate:
            // Backend POST sorğusunda JSON gözləyir, ona görə boş obyekt: {}
            return EmptyBody()
        case .delete, .getSalesAssociates:
            return nil
        }
    }
}

/// Gövdəsi olmayan POST sorğuları üçün `{}` kimi göndərilir.
private struct EmptyBody: Encodable {}
