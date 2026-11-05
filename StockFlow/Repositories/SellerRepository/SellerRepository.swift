//
//  SellerRepository.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import Foundation

protocol SellerRepository {
    func addSeller(request: SellerRequest) async throws -> SellerResponse
    func getSellers() async throws -> [SellerResponse]

    func deleteSeller(id: Int) async throws
    
    func updateSeller(id: Int, request: UpdateSellerRequest) async throws -> SellerResponse
    
    func deactivateSeller(id: Int) async throws -> SellerResponse
        func activateSeller(id: Int) async throws -> SellerResponse
    }

final class DefaultSellerRepository: SellerRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func addSeller(request: SellerRequest) async throws -> SellerResponse {
        try await networkService.request(SellerEndpoint.addSeller(request))
    }
    
    func getSellers() async throws -> [SellerResponse] {
        try await networkService.request(SellerEndpoint.getSellers)
    }
    
    func deleteSeller(id: Int) async throws  {
       try await networkService.requestVoid(SellerEndpoint.delete(id: id))
    }
    
    func updateSeller(id: Int, request: UpdateSellerRequest) async throws -> SellerResponse {
        try await networkService.request(SellerEndpoint.editSeller(id: id, request: request))
    }
    
    func deactivateSeller(id: Int) async throws -> SellerResponse {
            try await networkService.request(SellerEndpoint.deactivate(id: id))
        }

        func activateSeller(id: Int) async throws -> SellerResponse {
            try await networkService.request(SellerEndpoint.activate(id: id))
        }
}
