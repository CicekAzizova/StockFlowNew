//
//  PaymentMethod+Title.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

extension PaymentMethod {
    var title: LocalizedStringKey {
        switch self {
        case .cash: "Cash"
        case .card: "Card"
        case .transfer: "Transfer"
        case .other: "Other"
        case .mixed: "Mixed"
        }
    }
}
