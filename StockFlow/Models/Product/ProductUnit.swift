//
//  ProductUnit.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import Foundation

/// Məhsulun satış vahidi. Raw dəyər backend-dəki dəyərlə eynidir.
enum ProductUnit: String, CaseIterable, Codable {
    case piece
    case kg
    case l
    case pack

    var title: LocalizedStringResource {
        switch self {
        case .piece: "Piece"
        case .kg: "Kg"
        case .l: "Litre"
        case .pack: "Pack"
        }
    }
}
