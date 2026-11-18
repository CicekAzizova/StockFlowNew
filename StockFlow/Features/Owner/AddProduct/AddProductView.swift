//
//  AddProductsView.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//


import SwiftUI

struct AddProductView: View {
    
    @State private var viewModel: AddProductViewModel
    @FocusState private var focusField: AddProductFocusedField?
    @Binding var path: NavigationPath
    @State private var showScanner = false
    @State private var showsExtras: Bool
    
    let product: ProductsResponse?
    
    private var isEditMode: Bool {
        viewModel.product != nil
    }
    
    init(
        viewModel: AddProductViewModel,
        path: Binding<NavigationPath>
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.product = viewModel.product
        self._path = path
        self._showsExtras = State(initialValue: viewModel.hasExtraInfo)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                content
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadLocations() }
        .task(id: viewModel.sku) {
            await viewModel.barcodeChanged()
        }
        .onChange(of: viewModel.price) { viewModel.validationMessage = nil }
        .fullScreenCover(isPresented: $showScanner) {
            NavigationStack {
                BarcodeInputView(showsManualEntry: false) { code in
                    viewModel.sku = code
                    showScanner = false
                }
                .navigationTitle("Scan barcode")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showScanner = false }
                    }
                }
            }
        }
    }
    @ViewBuilder
    private var footer: some View {
        if case .success = viewModel.state {
            EmptyView()
        } else {
            VStack(spacing: 8) {
                if let message = viewModel.validationMessage {
                    Text(LocalizedStringKey(message))
                        .font(.inter(.regular, size: 13))
                        .foregroundStyle(.error)
                        .multilineTextAlignment(.center)
                }

                if case .error(let message) = viewModel.state {
                    Text(message)
                        .font(.inter(.regular, size: 13))
                        .foregroundStyle(.error)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    if viewModel.step == 2 {
                        Button("Back") {
                            viewModel.goToPreviousStep()
                        }
                        .font(.inter(.bold, size: 16))
                        .foregroundStyle(.textPrimary)
                        .frame(width: 96, height: 56)
                        .background(Color.surface, in: Capsule())
                        .overlay { Capsule().stroke(Color.gray.opacity(0.25), lineWidth: 1) }
                    }

                    if viewModel.step == 1 {
                        AddProductPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                            Task { await viewModel.goToNextStep() }
                        }
                    } else {
                        AddProductPrimaryButton(
                            title: isEditMode ? "Save Product" : "Create product",
                            systemImage: "checkmark.circle",
                            isLoading: viewModel.state.isLoading
                        ) {
                            Task { await submitProduct() }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Color.background)
        }
    }
    
    // MARK: - Add Product Screen
    private var addProductScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.step == 1 {
                    stepOne
                } else {
                    stepTwo
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            BrandScreenHeader(
                title: isEditMode ? LocalizedStringKey("Edit Product") : LocalizedStringKey("Add Product"),
                subtitle: String(localized: "Products"),
                showsBackButton: true
            )
            AddProductStepBar(step: viewModel.step)
        }
        .padding(.bottom, 16)
        .brandHeaderBackground()
    }
    
    // MARK: - Form
    
    private func field(
        _ title: LocalizedStringKey,
        _ placeholder: LocalizedStringKey,
        _ focus: AddProductFocusedField,
        next: AddProductFocusedField?,
        keyboard: UIKeyboardType = .default,
        icon: String? = nil,
        iconAction: (() -> Void)? = nil,
        text: Binding<String>
    ) -> some View {
        AppTextFieldView(
            title: title,
            placeholder: placeholder,
            icon: icon,
            focusedField: focus,
            keyboardType: keyboard,
            submitLabel: next == nil ? .done : .next,
            onSubmit: { focusField = next },
            iconAction: iconAction,
            text: text,
            focusedFieldBinding: $focusField
        )
    }
    
    // MARK: - Step 1: Basic info

    @ViewBuilder
    private var stepOne: some View {
        AddProductImageView(viewModel: viewModel)

        ProductFormField(
            title: "Barcode",
            placeholder: "Scan or type the code",
            focus: .sku,
            onSubmit: { focusField = .name },
            text: $viewModel.sku,
            focusBinding: $focusField
        ) {
            ScanPillButton { showScanner = true }
        }

        barcodeHint

        ProductFormField(
            title: "Product name",
            placeholder: "e.g. Wireless Mouse",
            focus: .name,
            submitLabel: .done,
            text: $viewModel.name,
            focusBinding: $focusField
        )
        SubcategoryPicker(selected: $viewModel.subcategory)
        UnitSegmentedControl(selection: $viewModel.unit)
    }
    
    @ViewBuilder
    private var barcodeHint: some View {
        switch viewModel.barcodeStatus {
        case .available:
            Label("No product with this barcode yet", systemImage: "checkmark.circle")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(Color.brandTeal)
        case .taken:
            Label("A product with this barcode already exists", systemImage: "exclamationmark.circle")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.error)
        case .checking:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Checking…")
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
            }
        case .unchecked, .failed:
            EmptyView()
        }
    }


    // MARK: - Step 2: Price & stock

    @ViewBuilder
    private var stepTwo: some View {
        HStack(alignment: .top, spacing: 12) {
            ProductFormField(
                title: "Cost price",
                placeholder: "0.00",
                focus: .costPrice,
                keyboard: .decimalPad,
                text: $viewModel.costPrice,
                focusBinding: $focusField
            ) {
                Text(verbatim: AppCurrency.code)
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
            }

            ProductFormField(
                title: "Selling price",
                placeholder: "0.00",
                focus: .price,
                keyboard: .decimalPad,
                text: $viewModel.price,
                focusBinding: $focusField
            ) {
                Text(verbatim: AppCurrency.code)
                    .font(.inter(.regular, size: 13))
                    .foregroundStyle(.textSecondary)
            }
        }

        if let profit = viewModel.profit, let margin = viewModel.margin {
            ProfitCard(profit: profit, margin: margin)
        }

        if viewModel.usesLocationStocks {
            StockByLocationCard(viewModel: viewModel)
        } else {
            field("Quantity", "Units in stock, e.g. 50", .quantity, next: .lowStockLimit, keyboard: .numberPad, text: $viewModel.quantity)

            if let locationName = ActiveLocationStore.name {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Quantity is saved for \(locationName)")
                }
                .font(.inter(.regular, size: 12))
                .foregroundStyle(Color.brandTeal)
            }
        }
        LowStockCard(
            value: Binding(
                get: { Int(viewModel.lowStockLimit) ?? 5 },
                set: { viewModel.lowStockLimit = String($0) }
            )
        )

        extrasSection
    }
    
    // MARK: - Optional info

    private var extrasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.snappy) { showsExtras.toggle() }
            } label: {
                HStack {
                    Text("Additional info (optional)")
                        .font(.inter(.bold, size: 15))
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.textSecondary)
                        .rotationEffect(.degrees(showsExtras ? 180 : 0))
                }
                .padding(14)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            if showsExtras {
                ProductFormField(
                    title: "Discount (%)",
                    placeholder: "Leave empty for none",
                    focus: .discount,
                    keyboard: .decimalPad,
                    onSubmit: { focusField = .weight },
                    text: $viewModel.discount,
                    focusBinding: $focusField
                )

                ProductFormField(
                    title: "Weight",
                    placeholder: "e.g. 330",
                    focus: .weight,
                    keyboard: .decimalPad,
                    onSubmit: { focusField = .size },
                    text: $viewModel.weight,
                    focusBinding: $focusField
                ) {
                    Menu {
                        Picker("Unit", selection: $viewModel.weightUnit) {
                            ForEach(AddProductViewModel.weightUnits, id: \.self) { unit in
                                Text(verbatim: unit).tag(unit)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(verbatim: viewModel.weightUnit)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(.inter(.bold, size: 14))
                        .foregroundStyle(Color.brandTeal)
                    }
                }

                ProductFormField(
                    title: "Size",
                    placeholder: "e.g. 30 × 20 × 10 cm, or M",
                    focus: .size,
                    onSubmit: { focusField = .description },
                    text: $viewModel.size,
                    focusBinding: $focusField
                )

                ProductFormField(
                    title: "Description",
                    placeholder: "Short product description",
                    focus: .description,
                    submitLabel: .done,
                    text: $viewModel.description,
                    focusBinding: $focusField
                )
            }
        }
    }
    
    // MARK: - Submit Product
    
    @MainActor
    private func submitProduct() async {
        
        await viewModel.saveProduct()
        
        if case .success = viewModel.state {
            
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }
    
    // MARK: - Content State
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            addProductScreen
            
        case .success:
            Color.clear
            
        case .error:
            addProductScreen
        }
    }
}
