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
    
    private var deleteButton: some View {
        BrandHeaderIconButton(
            systemImage: "trash",
            accessibilityLabel: "Delete"
        ) {
            showingDeleteConfirmation = true
        }
    }
    private var overviewTab: some View {
        VStack(spacing: 0) {
            InfoRow(title: "Category", value: categoryName)
            Divider().padding(.vertical, 12)
            InfoRow(title: "Barcode", value: product.sku)
            Divider().padding(.vertical, 12)
            InfoRow(title: "Total stock", localizedValue: "\(product.quantity) units")
            Divider().padding(.vertical, 12)
            InfoRow(title: "Low-stock threshold", localizedValue: "\(product.lowStockLimit) units")
            Divider().padding(.vertical, 12)
            InfoRow(title: "Sold this month", localizedValue: "\(product.soldThisMonth) units")
        }
        .font(.inter(.regular, size: 15))
        .padding(20)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .overview: overviewTab
        case .stock: stockTab
        case .history: EmptyView()   // növbəti addım
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
                : nil
            ) {
                if canManageProducts { deleteButton }
            }
            
            ScrollView {
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
    }}
