//
//  PaymentView.swift
//  StockFlow
//
//  Created by Cicek on 24.11.26.
//

import SwiftUI

struct PaymentView: View {

    @State private var viewModel: PaymentViewModel
    /// Satış yaranandan sonra "tamamlandı" ekranını valideyn göstərir.
    let onCompleted: (CreateSaleResponse) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool

    init(viewModel: PaymentViewModel, onCompleted: @escaping (CreateSaleResponse) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCompleted = onCompleted
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    methodButtons
                    details
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.background)
        .safeAreaInset(edge: .bottom) {
            completeButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.kind) {
            isAmountFocused = false
        }
        .onChange(of: isCompleted) {
            if case .completed(let response) = viewModel.state {
                onCompleted(response)
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
        VStack(spacing: 10) {
            BrandScreenHeader(
                title: "Payment",
                subtitle: String(localized: "New sale"),
                showsBackButton: true
            ) {
                EmptyView()
            }

            VStack(spacing: 2) {
                Text("Amount due")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))

                Text(verbatim: viewModel.total.asCurrency)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 4)
        }
        .padding(.bottom, 14)
        .brandHeaderBackground()
    }

    // MARK: - Ödəniş növü

    private var methodButtons: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(SalePaymentKind.allCases, id: \.self) { kind in
                methodButton(kind)
            }
        }
    }

    private func methodButton(_ kind: SalePaymentKind) -> some View {
        let isSelected = viewModel.kind == kind

        return Button {
            withAnimation(.snappy) { viewModel.kind = kind }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon(for: kind))
                    .font(.title3)
                Text(title(for: kind))
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color.brandDark : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.brandGreen : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func icon(for kind: SalePaymentKind) -> String {
        switch kind {
        case .cash: "banknote"
        case .card: "creditcard"
        case .transfer: "arrow.left.arrow.right"
        case .mixed: "square.split.2x1"
        }
    }

    private func title(for kind: SalePaymentKind) -> LocalizedStringKey {
        switch kind {
        case .cash: "Cash"
        case .card: "Card"
        case .transfer: "Transfer"
        case .mixed: "Mixed"
        }
    }

    // MARK: - Növə görə detallar

    @ViewBuilder
    private var details: some View {
        switch viewModel.kind {
        case .cash:
            cashSection
        case .mixed:
            mixedSection
        case .card, .transfer:
            EmptyView()
        }
    }

    private var cashSection: some View {
        VStack(spacing: 12) {
            amountField(title: "Received from customer", text: $viewModel.receivedText)

            if !viewModel.quickAmounts.isEmpty {
                HStack(spacing: 8) {
                    ForEach(viewModel.quickAmounts, id: \.self) { amount in
                        quickButton(amount)
                    }
                }
            }

            if let change = viewModel.change {
                resultRow(title: "Change", value: change.asCurrency)
            }
        }
    }

    private var mixedSection: some View {
        VStack(spacing: 12) {
            amountField(title: "Paid in cash", text: $viewModel.cashPartText)
            resultRow(title: "Rest by card", value: viewModel.cardPart.asCurrency)
        }
    }

    // MARK: - Kiçik hissələr

    private func amountField(title: LocalizedStringKey, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .padding(14)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.brandGreen.opacity(isAmountFocused ? 1 : 0.3))
                )
        }
    }

    private func quickButton(_ amount: Double) -> some View {
        Button {
            viewModel.receivedText = amount.formatted(.number.precision(.fractionLength(0...2)))
        } label: {
            Text(verbatim: amount.formatted(.number.precision(.fractionLength(0...2))))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.surface, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func resultRow(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(verbatim: value)
                .font(.headline)
                .foregroundStyle(Color.brandGreen)
        }
        .font(.subheadline)
        .padding(14)
        .background(Color.brandGreen.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Tamamla

    private var completeButton: some View {
        Button {
            isAmountFocused = false
            Task { await viewModel.complete() }
        } label: {
            Group {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Complete sale", systemImage: "checkmark.circle")
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.brandDark, .brandGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
        }
        .disabled(!viewModel.canComplete)
        .opacity(viewModel.canComplete ? 1 : 0.5)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }
}
