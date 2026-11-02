//
//  AddSalesAssociateView.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//
import SwiftUI

struct AddSalesAssociateView: View {
    
    @State var viewModel: AddSalesAssociateViewModel
    @FocusState private var focusedField: AddSalesFocusedField?
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            content
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(24)
        }
        .navigationTitle(viewModel.isEdit ? LocalizedStringKey("Edit Sales Associate") : LocalizedStringKey("Add Sales Associate"))
        
    }
    
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
            
        }
    }
    
    var salesAssociateButton: some View  {
        AppButtonView(
            title: viewModel.isEdit ? "Save Changes" : "Create Sales Associate",
            isLoading: viewModel.state.isLoading ,
            background: .brandPrimary) {
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
            salesAssociateButton
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
    }
}
