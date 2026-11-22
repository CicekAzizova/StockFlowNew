//
//  RestockSheet.swift
//  StockFlow
//
//  Created by Cicek on 06.11.26.
//
import SwiftUI

/// Qalığı artırmaq üçün pəncərə: neçə ədəd əlavə olunacağını yazırsan.
struct RestockSheet: View {

    let product: ProductsResponse
    let isSaving: Bool
    let errorMessage: String?
    /// true olsa, 2+ məkan varsa məkan seçimi görünür.
    var showsLocationPicker = false
    /// (əlavə olunacaq say, seçilmiş məkan id-si). Seçim yoxdursa id nil olur.
    let onConfirm: (Int, Int?) -> Void

    @State private var selectedLocationId: Int?

    @Environment(\.dismiss) private var dismiss
    @State private var quantityText = ""
    @State private var contentHeight: CGFloat = 480
    @FocusState private var isFocused: Bool

    private let quickAmounts = [10, 20, 50]

    private var quantity: Int { Int(quantityText) ?? 0 }
    
    private var isValid: Bool { quantity >= 1 && quantity <= 1_000_000 }
    
    private var pickerVisible: Bool { showsLocationPicker && product.stocks.count > 1 }

    /// Seçilmiş məkanın qalığı (seçim yoxdursa ümumi).
    private var currentQuantity: Int {
        guard pickerVisible,
              let stock = product.stocks.first(where: { $0.locationId == selectedLocationId })
        else { return product.quantity }
        return stock.quantity
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.brandTeal)
                .frame(width: 56, height: 56)
                .background(Color.brandTeal.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                .padding(.top, 24)

            Text("Restock")
                .font(.title3.bold())
                .foregroundStyle(Color.textPrimary)

            productCard
            
            if pickerVisible {
                locationPicker
            }
            
            quantityEditor

            quickChips

            if isValid {
                Text("New stock: \(currentQuantity + quantity)")
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.error)
                    .multilineTextAlignment(.center)
            }

            buttons
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            contentHeight = height
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(Color.surface)
        .onChange(of: quantityText) { _, newValue in
            // Yalnız rəqəmlərə icazə var.
            let digits = newValue.filter(\.isNumber)
            if digits != newValue { quantityText = digits }
        }
        .onAppear {
            selectedLocationId = ActiveLocationStore.id ?? product.stocks.first?.locationId
        }
    }

    // MARK: - Parts

    private var productCard: some View {
        HStack(spacing: 12) {
            RemoteImageView(
                imageUrl: product.imageUrls?.first,
                width: 40,
                height: 40,
                cornerRadius: 10
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("Current stock: \(currentQuantity)")
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.background, in: RoundedRectangle(cornerRadius: 14))
    }

    private var quantityEditor: some View {
        HStack(spacing: 12) {
            stepButton(systemImage: "minus") {
                setQuantity(max(0, quantity - 1))
            }

            TextField("0", text: $quantityText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title.bold())
                .foregroundStyle(Color.textPrimary)
                .focused($isFocused)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Color.background, in: RoundedRectangle(cornerRadius: 14))

            stepButton(systemImage: "plus") {
                setQuantity(quantity + 1)
            }
        }
    }

    private var quickChips: some View {
        HStack(spacing: 8) {
            ForEach(quickAmounts, id: \.self) { amount in
                Button {
                    setQuantity(quantity + amount)
                } label: {
                    Text(verbatim: "+\(amount)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.brandTeal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.brandTeal.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            Button {
                isFocused = false
                onConfirm(quantity, pickerVisible ? selectedLocationId : nil)
            } label: {
                Group {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Label("Add to stock", systemImage: "plus")
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Color.brandTeal.opacity(isValid && !isSaving ? 1 : 0.4),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isValid || isSaving)

            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.textSecondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var locationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(product.stocks) { stock in
                    let isSelected = stock.locationId == selectedLocationId
                    Button {
                        selectedLocationId = stock.locationId
                    } label: {
                        Text(verbatim: stock.locationName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.textPrimary)
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(
                                isSelected ? Color.brandTeal : Color.textSecondary.opacity(0.12),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 56, height: 56)
                .background(Color.textSecondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func setQuantity(_ value: Int) {
        quantityText = value == 0 ? "" : String(min(value, 1_000_000))
    }
}
