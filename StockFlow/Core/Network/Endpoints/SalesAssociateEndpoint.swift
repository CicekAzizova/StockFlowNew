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
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var method: HttpMethod {
        switch self {
        case .addSalesAssociate:
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
        case .delete:
            return nil
        case .getSalesAssociates:
            return nil
        case .editSalesAssociate(_, let request):
            return request
        }
    }
    
}
