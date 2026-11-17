//
//  AddSellerView.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//
import SwiftUI

struct AddSellerView: View {
    
    @State var viewModel: AddSellerViewModel
    @FocusState private var focusedField: AddSalesFocusedField?
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                header
                content
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)

    }
    
    
    // MARK: - Header

    private var header: some View {
        BrandScreenHeader(
            title: viewModel.isEdit
                ? LocalizedStringKey("Edit Sales Associate")
                : LocalizedStringKey("Add Sales Associate"),
            showsBackButton: true
        )
        .padding(.bottom, 16)
        .brandHeaderBackground()
    }

    // MARK: - Content
    
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle:
            associateScreen
        case .loading:
            ProgressView(viewModel.isEdit ? LocalizedStringKey("Saving...") : LocalizedStringKey("Creating..."))
        case .success(_):
            ProgressView(viewModel.isEdit ? LocalizedStringKey("Saved successfully...") : LocalizedStringKey("Created successfully..."))
        case .error(let message):
            VStack(spacing: 12) {
                associateScreen

                Text(message)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }
    
    var associateForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppTextFieldView(
                title: "Name",
                placeholder: "Name",
                icon: nil,
                focusedField: .name,
                errorMessage: viewModel.nameError,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .surname
                },
                text: $viewModel.name,
                focusedFieldBinding: $focusedField
            )
            
            AppTextFieldView(
                title: "Surname",
                placeholder: "Surname",
                icon: nil,
                focusedField: .surname,
                errorMessage: viewModel.surnameError,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .fin
                },
                text: $viewModel.surname,
                focusedFieldBinding: $focusedField
            )
            
            AppTextFieldView(
                title: "Fin",
                placeholder: "Fin",
                icon: nil,
                focusedField: .fin,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .phone
                },
                text: $viewModel.fin,
                focusedFieldBinding: $focusedField
            )
            
            AppTextFieldView(
                title: "Phone number",
                placeholder: "Phone number",
                icon: nil,
                focusedField: .phone,
                keyboardType: .numberPad,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .email
                },
                text: $viewModel.phone,
                focusedFieldBinding: $focusedField
            )
            
            AppTextFieldView(
                title: "Email",
                placeholder: "Email",
                icon: nil,
                focusedField: .email,
                errorMessage: viewModel.emailError,
                textContentType: .emailAddress,
                keyboardType: .emailAddress,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .password
                },
                text: $viewModel.email,
                focusedFieldBinding: $focusedField
            )
            
            AppTextFieldView(
                title: viewModel.isEdit ? "New password" : "Password" ,
                placeholder: viewModel.isEdit ? "Leave empty to keep current" : "Password",
                icon: nil,
                focusedField: .password,
                errorMessage: viewModel.passwordError,
                textContentType: .newPassword,
                submitLabel: .done,
                text: $viewModel.password,
                focusedFieldBinding: $focusedField
            )
            if viewModel.stores.count > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Works at")
                        .font(.inter(.medium, size: 14))
                        .foregroundStyle(.textPrimary)

                    Menu {
                        Picker("Works at", selection: $viewModel.selectedLocationId) {
                            ForEach(viewModel.stores) { store in
                                Text(verbatim: store.name).tag(Optional(store.id))
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "storefront")
                                .foregroundStyle(Color.brandTeal)

                            Text(verbatim: viewModel.stores.first { $0.id == viewModel.selectedLocationId }?.name ?? "")
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
            
        }
    }
    
    var sellerButton: some View  {
        AppButtonView(
            title: viewModel.isEdit ? "Save Changes" : "Create Sales Associate",
            isLoading: viewModel.state.isLoading ,
            usesBrandGradient: true) {
                Task {
                  await viewModel.save()
                    
                    if case .success = viewModel.state {
                        if !path.isEmpty {
                            path.removeLast()
                        }
                    }
                }
            }
            .padding(.top, 24)
    }
    
    var associateScreen: some View {
        ScrollView(showsIndicators: false) {
            associateForm
            sellerButton
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .task { await viewModel.loadStores() }
    }
}
