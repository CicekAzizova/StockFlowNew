//
//  SalesDateRangeSheet.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// "Tarix seç" üçün aşağıdan açılan pəncərə.
struct SalesDateRangeSheet: View {

    @State private var from: Date
    @State private var to: Date
    let onApply: (Date, Date) -> Void

    @Environment(\.dismiss) private var dismiss

    init(from: Date, to: Date, onApply: @escaping (Date, Date) -> Void) {
        _from = State(initialValue: from)
        _to = State(initialValue: to)
        self.onApply = onApply
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Pick date")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                DatePicker("From", selection: $from, in: ...Date.now, displayedComponents: .date)
                DatePicker("To", selection: $to, in: from...Date.now, displayedComponents: .date)
            }
            .tint(Color.brandTeal)
            .onChange(of: from) {
                if to < from { to = from }
            }

            Button {
                onApply(from, to)
                dismiss()
            } label: {
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
        }
        .padding(20)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
}
