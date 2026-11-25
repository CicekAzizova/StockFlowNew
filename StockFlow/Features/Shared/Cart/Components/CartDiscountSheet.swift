//
//  CartDiscountSheet.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Kassirin endirimi: manat və ya faiz.
struct CartDiscountSheet: View {

    private enum Kind: Hashable {
        case amount, percent
    }

    /// Faiz hesablamaq və cəmdən çox olmasın deyə: məhsul endirimlərindən sonrakı cəm.
    let discountedSubtotal: Double
    let current: CartViewModel.ManualDiscount
    let onApply: (CartViewModel.ManualDiscount) -> Void

    @State private var kind: Kind
    @State private var text: String
    @Environment(\.dismiss) private var dismiss

    init(
        discountedSubtotal: Double,
        current: CartViewModel.ManualDiscount,
        onApply: @escaping (CartViewModel.ManualDiscount) -> Void
    ) {
        self.discountedSubtotal = discountedSubtotal
        self.current = current
        self.onApply = onApply

        switch current {
        case .none:
            _kind = State(initialValue: .percent)
            _text = State(initialValue: "")
        case .amount(let value):
            _kind = State(initialValue: .amount)
            _text = State(initialValue: Self.format(value))
        case .percent(let value):
            _kind = State(initialValue: .percent)
            _text = State(initialValue: Self.format(value))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Discount")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Picker("Type", selection: $kind) {
                Text("Percent").tag(Kind.percent)
                Text("Amount").tag(Kind.amount)
            }
            .pickerStyle(.segmented)

            TextField(kind == .percent ? "Percent" : "Amount", text: $text)
                .keyboardType(.decimalPad)
                .font(.title3.weight(.semibold))
                .padding(14)
                .background(Color.background, in: RoundedRectangle(cornerRadius: 14))

            preview

            Button(action: apply) {
                Text("Apply")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.brandDark, .brandGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule()
                    )
            }

            if current != .none {
                Button("Remove discount", role: .destructive) {
                    onApply(.none)
                    dismiss()
                }
                .font(.subheadline)
            }
        }
        .padding(20)
        .presentationDetents([.height(current == .none ? 340 : 390)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Hesablama

    private var value: Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    /// Yazılan endirimin manatla qarşılığı (kassir nəticəni görsün).
    private var previewAmount: Double {
        let raw = kind == .percent ? discountedSubtotal * min(value, 100) / 100 : value
        return (min(raw, discountedSubtotal) * 100).rounded() / 100
    }

    @ViewBuilder
    private var preview: some View {
        if value > 0 {
            HStack {
                Text("Discount")
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(verbatim: "−\(previewAmount.asCurrency)")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.brandGreen)
            }
            .font(.subheadline)
        }
    }

    private func apply() {
        onApply(kind == .percent ? .percent(value) : .amount(value))
        dismiss()
    }

    private static func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}
