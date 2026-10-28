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
    private let canManageProducts: Bool
    
    private var product: ProductsResponse {
        viewModel.product
    }
    init(
        viewModel: ProductDetailViewModel,
        path: Binding<NavigationPath>,
        canManageProducts: Bool = false

    ) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.canManageProducts = canManageProducts
    }
    
    private var imageGallery: some View {
        TabView {
            ForEach(
                Array((product.imageUrls ?? []).prefix(5).enumerated()),
                id: \.offset
            ) { _, imageUrl in
                RemoteImageView(
                    imageUrl: imageUrl,
                    width: 280,
                    height: 280,
                    cornerRadius: 16
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 280)
        .tabViewStyle(.page)
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.inter(.extraBold, size: 20))

                Text(product.sku)
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(product.stockStatus.text(quantity: product.quantity))
                .font(.inter(.bold, size: 11))
                .foregroundStyle(product.stockStatus.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(product.stockStatus.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var productInformation: some View {
        VStack(spacing: 20) {
            InfoRow(
                title: "Category",
                value: product.category
            )

            InfoRow(
                title: "Price",
                value: product.price.asCurrency)

            if product.hasDiscount {
                InfoRow(title: "Price after discount", value: product.discountedPrice.asCurrency)
            }
            InfoRow(
                title: "Current stock",
                localizedValue: "\(product.quantity) units"
            )

            InfoRow(
                title: "Low-stock threshold",
                localizedValue: "\(product.lowStockLimit) units"
            )
        }
        .font(.inter(.regular, size: 15))
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.border, lineWidth: 1)
        }
    }
    
    private var productDetailContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageGallery
                header
                productInformation
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            content
        }
            .navigationTitle("\(product.name) details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canManageProducts {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                path.append(ProductRoute.editProduct(product))
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.textPrimary)
                        }
                    }
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
}
