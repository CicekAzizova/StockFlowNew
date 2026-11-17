//
//  TransferRepository.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//
protocol TransferRepository {
    func createTransfer(_ request: CreateTransferRequest) async throws -> StockTransfer
}

final class DefaultTransferRepository: TransferRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func createTransfer(_ request: CreateTransferRequest) async throws -> StockTransfer {
        try await networkService.request(TransferEndpoint.create(request))
    }
}
