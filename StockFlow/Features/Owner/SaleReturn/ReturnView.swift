//
//  ReturnView.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

struct ReturnView: View {

    @State private var viewModel: ReturnViewModel
    /// Qaytarma yarandıqdan sonra valideyn ekranı yeniləyir.
    let onCompleted: () -> Void

    @Environment(\.dismiss) private var dismiss

    init(viewModel: ReturnViewModel, onCompleted: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCompleted = onCompleted
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    itemsSection
                    reasonSection
                    restockRow
                    refundRow
                }
                .padding(16)
            }
        }
        .background(Color.background)
        .safeAreaInset(edge: .bottom) {
            confirmButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: isCompleted) {
            if isCompleted {
                onCompleted()
                dismiss()
            }
        }
        .alert("Something went wrong", isPresented: isErrorShown) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            if case .error(let message) = viewModel.state {
                Text(verbatim: message)
            }
        }
    }

    // MARK: - Vəziyyət

    private var isCompleted: Bool {
        if case .completed = viewModel.state { return true }
        return false
    }

    private var isSubmitting: Bool {
        if case .submitting = viewModel.state { return true }
        return false
    }

    private var isErrorShown: Binding<Bool> {
        Binding(
            get: { if case .error = viewModel.state { return true } else { return false } },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    // MARK: - Header

    private var header: some View {
        BrandScreenHeader(
            title: "Return",
            subtitle: subtitle,
            showsBackButton: true
        ) {
            EmptyView()
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }

    private var subtitle: String {
        let sale = viewModel.sale
        let receipt = sale.receiptNo.map { "#\($0)" } ?? "#\(sale.id)"
        return "\(receipt) · \(sale.netTotal.asCurrency)"
    }

    // MARK: - Məhsullar

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Returned products")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Button("Select all") { viewModel.selectAll() }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.brandTeal)
            }

            VStack(spacing: 0) {
                ForEach(viewModel.items, id: \.id) { item in
                    itemRow(item)

                    if item.id != viewModel.items.last?.id {
                        Divider()
                    }
                }
            }
            .brandCard()
        }
    }

    private func itemRow(_ item: SaleItemResponse) -> some View {
        let selected = viewModel.isSelected(item)

        return HStack(spacing: 12) {
            Button {
                viewModel.toggle(item)
            } label: {
                Image(systemName: selected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.brandGreen : Color.textSecondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: item.productName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("\(item.returnableQuantity) left · \(unitPrice(item))")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 4)

            stepper(item)
        }
        .padding(.vertical, 10)
    }

    private func unitPrice(_ item: SaleItemResponse) -> String {
        guard item.quantity > 0 else { return item.lineTotal.asCurrency }
        return (item.lineTotal / Double(item.quantity)).asCurrency
    }

    private func stepper(_ item: SaleItemResponse) -> some View {
        HStack(spacing: 6) {
            stepButton(systemImage: "minus") { viewModel.decrement(item) }
                .disabled(viewModel.quantity(for: item) == 0)

            Text(verbatim: "\(viewModel.quantity(for: item))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .frame(minWidth: 20)

            stepButton(systemImage: "plus") { viewModel.increment(item) }
                .disabled(viewModel.quantity(for: item) >= item.returnableQuantity)
        }
        .padding(4)
        .background(Color.background, in: Capsule())
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 28, height: 28)
                .background(Color.surface, in: Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Səbəb

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reason")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textSecondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                ForEach(ReturnReason.allCases, id: \.self) { reason in
                    reasonChip(reason)
                }
            }
        }
    }

    private func reasonChip(_ reason: ReturnReason) -> some View {
        let isSelected = viewModel.reason == reason

        return Button {
            viewModel.reason = reason
        } label: {
            Text(title(for: reason))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? Color.brandDark : Color.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected ? Color.brandGreen.opacity(0.15) : Color.surface,
                    in: Capsule()
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color.brandGreen : .clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    private func title(for reason: ReturnReason) -> LocalizedStringKey {
        switch reason {
        case .damaged: "Damaged product"
        case .customerDeclined: "Customer declined"
        case .wrongItem: "Wrong product"
        case .other: "Other"
        }
    }

    // MARK: - Qalığa qaytar

    private var restockRow: some View {
        Toggle(isOn: $viewModel.restock) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Put products back in stock")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text("If they are not damaged, they go back on the shelf")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .tint(Color.brandGreen)
        .brandCard()
    }

    // MARK: - Məbləğ

    private var refundRow: some View {
        HStack {
            Text("To refund")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(verbatim: viewModel.total.asCurrency)
                .font(.title3.weight(.bold))
        }
        .foregroundStyle(Color.brandCoral)
        .padding(14)
        .background(Color.brandCoral.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Təsdiq

    private var confirmButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            Group {
                if isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Label("Confirm return", systemImage: "arrow.uturn.backward")
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.brandCoral, in: Capsule())
        }
        .disabled(!viewModel.canSubmit)
        .opacity(viewModel.canSubmit ? 1 : 0.5)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }
}
