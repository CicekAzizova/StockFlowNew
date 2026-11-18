//
//  StockStepper.swift
//  StockFlow
//
//  Created by Cicek on 18.11.26.
//

import SwiftUI

/// − 24 + : qalığı düymə ilə, basılı saxlamaqla və ya klaviaturadan dəyişir.
struct StockStepper: View {

    @Binding var value: Int
    @State private var repeatTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 4) {
            stepButton("minus", delta: -1)

            TextField("0", value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.inter(.bold, size: 16))
                .foregroundStyle(.textPrimary)
                .frame(width: 52)

            stepButton("plus", delta: 1)
        }
        .padding(4)
        .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func stepButton(_ icon: String, delta: Int) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.textPrimary)
            .frame(width: 34, height: 34)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture {
                value = max(0, value + delta)
            }
            .onLongPressGesture(minimumDuration: 0.4, perform: {}, onPressingChanged: { isPressing in
                isPressing ? startRepeating(delta) : stopRepeating()
            })
            .accessibilityLabel(delta > 0 ? "Increase" : "Decrease")
            .accessibilityAddTraits(.isButton)
    }

    /// 0.4 san basılı saxlayandan sonra təkrarlayır. 15 addımdan sonra ona qədər sürətlənir.
    private func startRepeating(_ delta: Int) {
        repeatTask?.cancel()
        repeatTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            var ticks = 0
            while !Task.isCancelled {
                value = max(0, value + delta * (ticks > 15 ? 10 : 1))
                ticks += 1
                try? await Task.sleep(for: .milliseconds(80))
            }
        }
    }

    private func stopRepeating() {
        repeatTask?.cancel()
        repeatTask = nil
    }
}
