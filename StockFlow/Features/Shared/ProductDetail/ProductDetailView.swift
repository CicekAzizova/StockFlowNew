//
//  ProductDetailView.swift
//  StockFlow
//
//  Created by Cicek on 02.10.26.
//
import SwiftUI

struct ProductDetailView: View {
    @State var viewModel: ProductDetailViewModel
    
    @Binding var path: NavigationPath
    @State private var showingDeleteConfirmation = false
    @State private var isTransferPresented = false
    @State private var isRestockPresented = false
    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss
    private let dependencies: AppDependencies?
    private let canManageProducts: Bool
    
    private var product: ProductsResponse {
        viewModel.product
    }
    init(
        viewModel: ProductDetailViewModel,
        path: Binding<NavigationPath>,
        canManageProducts: Bool = false,
        dependencies: AppDependencies? = nil
        
    ) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.canManageProducts = canManageProducts
        self.dependencies = dependencies
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            content
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isRestockPresented) {
            RestockSheet(
                product: product,
                isSaving: viewModel.isRestocking,
                errorMessage: viewModel.restockError,
                showsLocationPicker: true
            ) { quantity, locationId in
                Task {
                    if await viewModel.restock(quantity: quantity, locationId: locationId) {
                        isRestockPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $isTransferPresented) {
            if let dependencies {
                TransferStockSheet(
                    viewModel: dependencies.makeTransferStockViewModel(product: product),
                    onTransferred: { await viewModel.reload() }
                )
            }
        }
        
        .alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: { viewModel.actionError != nil },
                set: { if !$0 { viewModel.actionError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.actionError ?? "")
        }
    }
    
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            productDetailContent
            
        case .deleting:
            productDetailContent
                .overlay {
                    ProgressView("Deleting product...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            
        case .deleted:
            ContentUnavailableView(
                "Product Deleted",
                systemImage: "checkmark.circle",
                description: Text("The product has been successfully deleted.")
            )
            
        case .error(let message):
            ContentUnavailableView(
                "Something Went Wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
    
    /// Alt kateqoriyanın tərcümə olunmuş adı, tapılmasa köhnə category.
    private var categoryName: String {
        if let code = product.subcategory,
           let name = catalogStore.subcategory(code: code)?
            .names.value(for: languageManager.language) {
            return name
        }
        return product.category
    }
    
    private var subtitle: String {
        [product.sku, categoryName]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
    
    /// Paylaşma mətni: ad, qiymət, təsvir və ilk şəklin linki.
    private var shareText: String {
        var lines = [product.name, product.discountedPrice.asCurrency]
        if !product.description.isBlank {
            lines.append(product.description)
        }
        if let imageUrl = product.imageUrls?.first, !imageUrl.isEmpty {
            lines.append(imageUrl)
        }
        return lines.joined(separator: "\n")
    }
    
    private var deleteButton: some View {
        BrandHeaderIconButton(
            systemImage: "trash",
            accessibilityLabel: "Delete"
        ) {
            showingDeleteConfirmation = true
        }
    }
    
    private func valueRaw(_ text: String) -> some View {
           Text(verbatim: text)
               .font(.inter(.regular, size: 14))
               .foregroundStyle(.textSecondary)
               .lineLimit(1)
       }

    private func valueText(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.inter(.regular, size: 14))
            .foregroundStyle(.textSecondary)
            .lineLimit(1)
    }

    private var overviewTab: some View {
        VStack(spacing: 0) {
            AppRowView(icon: "tag", tint: .orange, title: "Category") {
                valueRaw(categoryName)
            }
            .compact()
            Divider()

            AppRowView(icon: "barcode", tint: .gray, title: "Barcode") {
                valueRaw(product.sku)
            }
            .compact()
            Divider()

            AppRowView(icon: "shippingbox", tint: .brandTeal, title: "Total stock") {
                valueText("\(product.quantity) units · \(product.stocks.count) locations")
            }
            .compact()
            Divider()

            lowStockRow
            Divider()

            AppRowView(icon: "receipt", tint: .blue, title: "Sold this month") {
                valueText("\(product.soldThisMonth) units")
            }
            .compact()

            if canManageProducts {
                Divider()
                AppRowView(icon: "cart", tint: .brandTeal, title: "On sale") {
                    Toggle("", isOn: Binding(
                        get: { product.isForSale },
                        set: { value in Task { await viewModel.setForSale(value) } }
                    ))
                    .labelsHidden()
                    .tint(.brandTeal)
                }
                .compact()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// Sahibdə basanda redaktə ekranı açılır (limit orada dəyişir).
    @ViewBuilder
    private var lowStockRow: some View {
        let row = AppRowView(icon: "exclamationmark.triangle", tint: .pending, title: "Low-stock threshold") {
            HStack(spacing: 6) {
                valueText("\(product.lowStockLimit) units")
                if canManageProducts {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.textSecondary)
                }
            }
        }
            .compact()

        if canManageProducts {
            Button {
                path.append(ProductRoute.editProduct(product))
            } label: {
                row
            }
            .buttonStyle(.plain)
        } else {
            row
        }
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .overview: overviewTab
        case .stock: stockTab
        case .history: historyTab
        }
    }
    
    private var productDetailContent: some View {
        VStack(spacing: 0) {
            ProductDetailHeader(
                product: product,
                subtitle: subtitle,
                onBack: { dismiss() },
                onEdit: canManageProducts
                ? { path.append(ProductRoute.editProduct(product)) }
                : nil,
                shareText: canManageProducts ? shareText : nil
            ) {
                if canManageProducts { deleteButton }
            }
            
            ScrollView {
                if !product.isForSale {
                    Label("Not for sale. Sellers can't sell this product.", systemImage: "pause.circle")
                        .font(.inter(.bold, size: 13))
                        .foregroundStyle(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.pending.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(8)
                }
                VStack(spacing: 16) {
                    ProductStatsCard(product: product, showsCost: canManageProducts)
                    
                    if canManageProducts {
                        ProductDetailTabPicker(selection: $viewModel.selectedTab)
                    }
                    
                    tabContent
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color.background)
        .confirmationDialog(
            isPresented: $showingDeleteConfirmation,
            title: "Delete Product",
            message: "Are you sure you want to delete this product?",
            confirmTitle: "Delete") {
                Task {
                    await viewModel.deleteProduct()
                    if case .deleted = viewModel.state { path.removeLast() }
                }
            }
    }
    
    private func location(for stock: ProductStock) -> StoreLocation? {
        dependencies?.locationSwitcher.locations.first { $0.id == stock.locationId }
    }
    
    private var stockTab: some View {
        VStack(spacing: 12) {
            HStack {
                Text("In \(product.stocks.count) locations total")
                    .font(.inter(.regular, size: 14))
                    .foregroundStyle(.textSecondary)
                
                Spacer()
                
                Text("\(product.quantity) units")
                    .font(.inter(.bold, size: 14))
                    .foregroundStyle(.textPrimary)
                
                Text(product.stockStatus == .outOfStock ? "Out" : product.stockStatus == .lowStock ? "Low" : "Normal")
                    .font(.inter(.bold, size: 12))
                    .foregroundStyle(product.stockStatus.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(product.stockStatus.backgroundColor, in: Capsule())
            }
            .padding(.horizontal, 4)
            
            ForEach(product.stocks) { stock in
                LocationStockCard(
                    name: stock.locationName,
                    location: location(for: stock),
                    quantity: stock.quantity,
                    lowStockLimit: product.lowStockLimit
                )
            }
            
            HStack(spacing: 12) {
                if dependencies != nil, product.stocks.count > 1 {
                    Button {
                        isTransferPresented = true
                    } label: {
                        Label("Transfer", systemImage: "arrow.left.arrow.right")
                            .font(.inter(.bold, size: 16))
                            .foregroundStyle(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.surface, in: Capsule())
                            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }
                
                Button {
                    viewModel.restockError = nil
                    isRestockPresented = true
                } label: {
                    Label("Add stock", systemImage: "plus")
                        .font(.inter(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [.brandDark, .brandGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }
            }
            .padding(.top, 4)
        }
    }
    
    
    /// "Gələn" köçürmə yazısı gizlədilir: bir köçürmə bir sətir göstərilir.
    private var visibleHistory: [StockMovement] {
        viewModel.history.filter { $0.type != .transferIn }
    }

    private var historyGroups: [(day: Date, items: [StockMovement])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: visibleHistory) {
            calendar.startOfDay(for: $0.date ?? .distantPast)
        }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    @ViewBuilder
    private func dayTitle(_ day: Date) -> some View {
        if Calendar.current.isDateInToday(day) {
            Text("Today")
        } else if Calendar.current.isDateInYesterday(day) {
            Text("Yesterday")
        } else {
            Text(day, format: .dateTime.day().month(.wide).year())
        }
    }

    private var historyTab: some View {
        VStack(spacing: 12) {
            if viewModel.history.isEmpty {
                if viewModel.isLoadingHistory {
                    ProgressView().padding(.top, 32)
                } else if let error = viewModel.historyError {
                    VStack(spacing: 12) {
                        Text(verbatim: error)
                            .font(.inter(.regular, size: 14))
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Try again") {
                            Task { await viewModel.loadHistory() }
                        }
                    }
                    .padding(.top, 32)
                } else {
                    ContentUnavailableView("No history yet", systemImage: "clock")
                        .padding(.top, 16)
                }
            } else {
                ForEach(historyGroups, id: \.day) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        dayTitle(group.day)
                            .font(.inter(.bold, size: 13))
                            .foregroundStyle(.textSecondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            ForEach(group.items) { movement in
                                StockMovementRow(movement: movement)
                                    .padding(.vertical, 12)
                                    .onAppear {
                                        if movement.id == visibleHistory.last?.id {
                                            Task { await viewModel.loadMoreHistory() }
                                        }
                                    }

                                if movement.id != group.items.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
        .task { await viewModel.loadHistoryIfNeeded() }
    }
    
}
