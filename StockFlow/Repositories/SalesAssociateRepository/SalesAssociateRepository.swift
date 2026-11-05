//
//  SalesAssociateRepository.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

protocol SalesAssociateRepository {
    func addSalesAssociate(request: SalesAssociateRequest) async throws -> SalesAssociateResponse
    func getSalesAssociates() async throws -> [SalesAssociateResponse]

    func deleteSalesAssociate(id: Int) async throws
    
    func updateSalesAssociate(id: Int, request: UpdateSalesAssociateRequest) async throws -> SalesAssociateResponse
    
    func deactivateSalesAssociate(id: Int) async throws -> SalesAssociateResponse
        func activateSalesAssociate(id: Int) async throws -> SalesAssociateResponse
    }

final class DefaultSalesAssociateRepository: SalesAssociateRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func addSalesAssociate(request: SalesAssociateRequest) async throws -> SalesAssociateResponse {
        try await networkService.request(SalesAssociateEndpoint.addSalesAssociate(request))
    }
    
    func getSalesAssociates() async throws -> [SalesAssociateResponse] {
        try await networkService.request(SalesAssociateEndpoint.getSalesAssociates)
    }
    
    func deleteSalesAssociate(id: Int) async throws  {
       try await networkService.requestVoid(SalesAssociateEndpoint.delete(id: id))
    }
    
    func updateSalesAssociate(id: Int, request: UpdateSalesAssociateRequest) async throws -> SalesAssociateResponse {
        try await networkService.request(SalesAssociateEndpoint.editSalesAssociate(id: id, request: request))
    }
    
    func deactivateSalesAssociate(id: Int) async throws -> SalesAssociateResponse {
            try await networkService.request(SalesAssociateEndpoint.deactivate(id: id))
        }

        func activateSalesAssociate(id: Int) async throws -> SalesAssociateResponse {
            try await networkService.request(SalesAssociateEndpoint.activate(id: id))
        }
}
