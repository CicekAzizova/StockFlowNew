//
//  TransferStockSheet.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//
import SwiftUI

struct TransferStockSheet: View {

    @State var viewModel: TransferStockViewModel
    /// Transfer uğurlu olandan sonra çağırılır (siyahıları təzələmək üçün).
    let onTransferred: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuantityFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Transfer stock")
                    .font(.inter(.bold, size: 20))
                    .foregroundStyle(.textPrimary)

                Text(verbatim: viewModel.product.name)
                    .font(.inter(.medium, size: 15))
                    .foregroundStyle(.textSecondary)

                locationMenu(title: "From", selection: $viewModel.fromLocationId)
                locationMenu(title: "To", selection: $viewModel.toLocationId)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Quantity")
                        .font(.inter(.medium, size: 14))
                        .foregroundStyle(.textPrimary)

                    TextField("0", text: $viewModel.quantity)
                        .keyboardType(.numberPad)
                        .focused($isQuantityFocused)
                        .padding(14)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Available at the source: \(viewModel.available)")
                        .font(.inter(.regular, size: 12))
                        .foregroundStyle(.textSecondary)
                }

                if let message = viewModel.errorMessage {
                    Text(verbatim: message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                AppButtonView(
                    title: "Transfer",
                    isLoading: viewModel.isSaving,
                    usesBrandGradient: true
                ) {
                    Task {
                        isQuantityFocused = false
                        if await viewModel.transfer() {
                            await onTransferred()
                            dismiss()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .presentationDetents([.medium, .large])
        .task { await viewModel.load() }
    }

    // MARK: - Məkan seçimi

    private func locationMenu(title: LocalizedStringKey, selection: Binding<Int?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.inter(.medium, size: 14))
                .foregroundStyle(.textPrimary)

            Menu {
                Picker(title, selection: selection) {
                    ForEach(viewModel.locations) { location in
                        Text(verbatim: location.name).tag(Optional(location.id))
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon(for: selection.wrappedValue))
                        .foregroundStyle(Color.brandTeal)

                    Text(verbatim: name(for: selection.wrappedValue))
                        .foregroundStyle(.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.textSecondary)
                }
                .padding(14)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func name(for id: Int?) -> String {
        viewModel.locations.first { $0.id == id }?.name ?? ""
    }

    private func icon(for id: Int?) -> String {
        viewModel.locations.first { $0.id == id }?.kind.icon ?? "storefront"
    }
}
