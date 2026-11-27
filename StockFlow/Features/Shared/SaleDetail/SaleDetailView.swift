//
//  SaleDetailView.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//
import SwiftUI

struct SaleDetailView: View {

    @State private var sale: SaleResponse
    private let repository: SalesRepository?
    private let canReturn: Bool
    private let productsStore: ProductsStore?
    private let locationSwitcher: LocationSwitcher?

    @State private var showsReturn = false

    init(
        sale: SaleResponse,
        repository: SalesRepository? = nil,
        canReturn: Bool = false,
        locationSwitcher: LocationSwitcher? = nil,
        productsStore: ProductsStore? = nil
    ) {
        _sale = State(initialValue: sale)
        self.repository = repository
        self.canReturn = canReturn
        self.locationSwitcher = locationSwitcher
        self.productsStore = productsStore
    }
    /// Məkan yalnız mağazada 1-dən çox məkan olanda göstərilir.
    /// Owner-də mağazada tək məkan varsa gizlədilir. Satıcıda siyahı gəlmir, məkan həmişə göstərilir.
    private var showsLocation: Bool {
        (locationSwitcher?.locations.count ?? 0) != 1
    }

    private var dateText: String {
        var text = sale.createdAt.formatted(date: .long, time: .shortened)
        if showsLocation, let name = sale.locationName {
            text += " · \(name)"
        }
        return text
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    receiptCard
                    infoTiles
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding(.top, -44) // kart gradientin üstünə çıxır
        }
        .background(Color.background)
        .safeAreaInset(edge: .bottom) {
            refundButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if let locationSwitcher, locationSwitcher.locations.isEmpty {
                await locationSwitcher.load()
            }
        }
        .sheet(isPresented: $showsReturn) {
            if let repository {
                ReturnView(
                    viewModel: ReturnViewModel(
                        repository: repository,
                        sale: sale,
                        productsStore: productsStore
                    )
                ) {
                    Task { await reload() }
                    NotificationCenter.default.post(name: .saleChanged, object: nil)
                }
            }
        }
    }
    // MARK: - Header

    private var header: some View {
        BrandScreenHeader(
            title: LocalizedStringKey(receiptTitle),
            subtitle: String(localized: "Sales"),
            showsBackButton: true
        ) {
            ShareLink(item: shareText) {
                BrandHeaderIcon(systemImage: "square.and.arrow.up")
            }
            .accessibilityLabel("Share")
        }
        .padding(.bottom, 58)
        .brandHeaderBackground()
    }

    private var receiptTitle: String {
        if let receiptNo = sale.receiptNo {
            return "#\(receiptNo)"
        }
        return "#\(sale.id)"
    }

    /// Paylaşılan qəbz mətni.
    private var shareText: String {
        var lines = ["\(receiptTitle) · \(dateText)"]
        
        for item in sale.items ?? [] {
            lines.append("\(item.productName) ×\(item.quantity): \(item.lineTotal.asCurrency)")
        }
        lines.append("\(String(localized: "Total")): \(sale.totalPrice.asCurrency)")
        return lines.joined(separator: "\n")
    }
    
    /// Qaytarmadan sonra qəbzi serverdən yenidən oxuyur.
    private func reload() async {
        guard let repository else { return }
        if let fresh = try? await repository.getSale(id: sale.id) {
            sale = fresh
        }
    }

    // MARK: - Qəbz kartı

    private var receiptCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(verbatim: sale.netTotal.asCurrency)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(verbatim: dateText)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    if sale.isReturned {
                        Text("Returned: \(sale.returnedAmount.asCurrency)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.brandCoral)
                    }
                }

                Spacer()

                Text(sale.paymentMethod.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandGreen.opacity(0.12), in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            DashedLine()

            HStack {
                Text("Total")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(verbatim: sale.netTotal.asCurrency)
                    .font(.title3.weight(.bold))
            }
            .foregroundStyle(Color.textPrimary)

            if let payments = sale.payments, payments.count > 1 {
                DashedLine()

                VStack(spacing: 6) {
                    ForEach(payments, id: \.method) { payment in
                        HStack {
                            Text(payment.paymentMethod.title)
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(verbatim: payment.amount.asCurrency)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.textPrimary)
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .brandCard()
    }

    private func itemRow(_ item: SaleItemResponse) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(verbatim: item.productName)
                        .foregroundStyle(Color.textPrimary)
                    Text(verbatim: "×\(item.quantity)")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .lineLimit(1)

                Label {
                    Text(verbatim: item.sku)
                } icon: {
                    Image(systemName: "barcode")
                }
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 8)

            Text(verbatim: item.lineTotal.asCurrency)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
        }
        .font(.subheadline)
    }
    // MARK: - Kiçik kartlar

    private var infoTiles: some View {
        HStack(spacing: 12) {
            tile(title: "Seller") {
                Label {
                    Text(verbatim: sale.sellerName ?? "-")
                } icon: {
                    Image(systemName: "person")
                        .foregroundStyle(Color.brandTeal)
                }
            }
            tile(title: "Payment") {
                Label {
                    Text(sale.paymentMethod.title)
                } icon: {
                    Image(systemName: paymentIcon)
                        .foregroundStyle(Color.brandTeal)
                }
            }
        }
    }

    private var paymentIcon: String {
        switch sale.paymentMethod {
        case .cash: "banknote"
        case .card: "creditcard"
        case .transfer: "arrow.left.arrow.right"
        case .other: "ellipsis.circle"
        case .mixed:
            "square.split.2x1"
        }
    }

    private func tile<Value: View>(
        title: LocalizedStringKey,
        @ViewBuilder value: () -> Value
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            value()
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandCard()
    }

    // MARK: - Qaytarma

    @ViewBuilder
    private var refundButton: some View {
        if canReturn, canReturnSomething {
            Button {
                showsReturn = true
            } label: {
                Label("Return", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandCoral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.surface, in: Capsule())
                    .overlay(Capsule().stroke(Color.brandCoral.opacity(0.3)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.background)
        }
    }

    /// Qaytarılacaq ədəd qalıbmı.
    private var canReturnSomething: Bool {
        (sale.items ?? []).contains { $0.returnableQuantity > 0 }
    }
}

/// Qəbz kartındakı nöqtəli ayırıcı xətt.
private struct DashedLine: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(Color.textSecondary.opacity(0.35))
            .frame(height: 1)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
