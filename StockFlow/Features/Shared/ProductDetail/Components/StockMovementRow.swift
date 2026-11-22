//
//  StockMovementRow.swift
//  StockFlow
//
//  Created by Cicek on 22.11.26.
//

import SwiftUI

/// Tarixçədə bir hərəkət. Dizayn: "Satış · Məkan", altında saat · istifadəçi · qeyd, sağda say.
struct StockMovementRow: View {

    let movement: StockMovement

    private var title: LocalizedStringKey {
        switch movement.type {
        case .initial: "Initial stock"
        case .sale: "Sale"
        case .restock: "Restock"
        case .transferIn, .transferOut: "Transfer"
        case .adjustment: "Adjustment"
        case .unknown: "Stock change"
        }
    }

    private var icon: String {
        switch movement.type {
        case .initial: "shippingbox"
        case .sale: "cart"
        case .restock: "plus"
        case .transferIn, .transferOut: "arrow.left.arrow.right"
        case .adjustment: "pencil"
        case .unknown: "questionmark"
        }
    }

    private var tint: Color {
        switch movement.type {
        case .initial, .restock: .success
        case .sale: .error
        case .transferIn, .transferOut: .blue
        case .adjustment: .pending
        case .unknown: .textSecondary
        }
    }

    /// Sağdakı say: köçürmədə işarəsiz, qalanlarda +/−.
    private var changeText: String {
        switch movement.type {
        case .transferIn, .transferOut:
            return "\(abs(movement.quantityChange))"
        default:
            return movement.quantityChange > 0 ? "+\(movement.quantityChange)" : "\(movement.quantityChange)"
        }
    }

    private var changeColor: Color {
        switch movement.type {
        case .transferIn, .transferOut: .blue
        case .adjustment: movement.quantityChange < 0 ? .error : .success
        default: tint
        }
    }

    /// "Kontact" və ya köçürmədə "Kontact → Test".
    private var place: String {
        switch movement.type {
        case .transferOut, .transferIn:
            [movement.locationName, movement.relatedLocationName]
                .compactMap { $0 }
                .joined(separator: " → ")
        default:
            movement.locationName
        }
    }

    /// "14:32 · Rəşad M. · #4 · Təchizatçıdan"
    private var details: String {
        var parts: [String] = []
        if let date = movement.date {
            parts.append(date.formatted(date: .omitted, time: .shortened))
        }
        if let userName = movement.userName, !userName.isEmpty {
            parts.append(userName)
        }
        if let receiptNo = movement.receiptNo {
            parts.append("#\(receiptNo)")
        }
        if let note = movement.note, !note.isEmpty {
            parts.append(note)
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(title)
                    Text(verbatim: "·")
                    Text(verbatim: place)
                }
                .font(.inter(.bold, size: 14))
                .foregroundStyle(.textPrimary)
                .lineLimit(1)

                Text(verbatim: details)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(verbatim: changeText)
                .font(.inter(.bold, size: 16))
                .foregroundStyle(changeColor)
        }
    }
}
