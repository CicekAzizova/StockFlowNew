//
//  ManualCodeEntryView.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

import SwiftUI

struct ManualCodeEntryView: View {
    var placeholder = "Enter barcode manually"
    let onSubmit: (String) -> Void

    @State private var code = ""

    private var trimmed: String {
        code.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $code)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(submit)

            Button("Find", action: submit)
                .buttonStyle(.borderedProminent)
                .disabled(trimmed.isEmpty)
        }
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}
