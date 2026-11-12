//
//  OnboardingView.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

import SwiftUI

enum OnboardingField: Hashable {
    case storeName, phone, city
}

struct OnboardingView: View {

    @State var viewModel: OnboardingViewModel
    @FocusState private var focusedField: OnboardingField?
    @Environment(\.locale) private var locale

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        switch viewModel.step {
                        case .store:
                            storeStep
                        case .categories:
                            categoriesStep
                        }

                        if let message = viewModel.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            BrandScreenHeader(
                title: viewModel.step == .store
                    ? LocalizedStringKey("Your store")
                    : LocalizedStringKey("Categories"),
                subtitle: "Step \(viewModel.step.rawValue + 1) of \(OnboardingViewModel.Step.allCases.count)"
            )

            // Proqres zolağı: keçilmiş addımlar tam ağ olur.
            HStack(spacing: 6) {
                ForEach(OnboardingViewModel.Step.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(.white.opacity(step.rawValue <= viewModel.step.rawValue ? 1 : 0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .brandHeaderBackground()
    }

    // MARK: - Step 1: store

    @ViewBuilder
    private var storeStep: some View {
        AppTextFieldView(
            title: "Store Name",
            placeholder: "Your store name",
            icon: nil,
            focusedField: OnboardingField.storeName,
            errorMessage: viewModel.nameError,
            submitLabel: .next,
            onSubmit: { focusedField = .phone },
            text: $viewModel.storeName,
            focusedFieldBinding: $focusedField
        )

        AppTextFieldView(
            title: "Store Phone",
            placeholder: "+994",
            icon: nil,
            focusedField: OnboardingField.phone,
            keyboardType: .phonePad,
            submitLabel: .next,
            onSubmit: { focusedField = .city },
            text: $viewModel.phone,
            focusedFieldBinding: $focusedField
        )

        Section("Country") {
            Picker("Country", selection: $viewModel.countryCode) {
                ForEach(sortedCountries) { country in
                    Text(country.name(in: locale)).tag(country.code)
                }
            }
            .pickerStyle(.menu)
            .pickerBox()
        }
        .onChange(of: viewModel.countryCode) {
            viewModel.countryChanged()
        }

        AppTextFieldView(
            title: "City",
            placeholder: "City",
            icon: nil,
            focusedField: OnboardingField.city,
            submitLabel: .done,
            onSubmit: { focusedField = nil },
            text: $viewModel.city,
            focusedFieldBinding: $focusedField
        )

        Section("Currency") {
            Picker("Currency", selection: $viewModel.currency) {
                ForEach(CurrencyOption.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .pickerBox()
        }
    }

    private var sortedCountries: [CountryOption] {
        CountryOption.all.sorted {
            $0.name(in: locale).localizedStandardCompare($1.name(in: locale)) == .orderedAscending
        }
    }

    // MARK: - Step 2: categories

    @ViewBuilder
    private var categoriesStep: some View {
        Text("What do you sell? Choose up to 5 categories.")
            .font(.inter(.regular, size: 15))
            .foregroundStyle(.textSecondary)
            .padding(.bottom, 16)

        CategoryPicker(selected: $viewModel.selectedCategories)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 12) {
            if viewModel.step == .categories {
                Button {
                    viewModel.back()
                } label: {
                    Text("Back")
                        .font(.inter(.bold, size: 16))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, 24)
                        .frame(height: 50)
                        .background(.border)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isSaving)
            }

            AppButtonView(
                title: viewModel.step == .store ? LocalizedStringKey("Continue") : LocalizedStringKey("Finish"),
                isLoading: viewModel.isSaving,
                background: .brandPrimary
            ) {
                focusedField = nil
                Task {
                    switch viewModel.step {
                    case .store: await viewModel.continueFromStore()
                    case .categories: await viewModel.finish()
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.background)
    }
}

// MARK: - Picker styling (Currency sahəsi ilə eyni görünüş)

private extension View {
    func pickerBox() -> some View {
        self
            .tint(Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.border)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
