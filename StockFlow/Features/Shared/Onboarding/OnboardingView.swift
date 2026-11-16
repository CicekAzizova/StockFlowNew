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
    let onSignOut: () -> Void
    @FocusState private var focusedField: OnboardingField?
    @Environment(\.locale) private var locale
    @State private var isBackOptionsPresented = false

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
        .confirmationDialog(
            "Go back?",
            isPresented: $isBackOptionsPresented,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                onSignOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                BrandHeaderIconButton(
                    systemImage: "chevron.left",
                    accessibilityLabel: "Back"
                ) {
                    if viewModel.step == .store {
                        isBackOptionsPresented = true
                    } else {
                        viewModel.back()
                    }
                }
                .disabled(viewModel.isSaving)

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "Step \(viewModel.step.rawValue + 1) of \(OnboardingViewModel.Step.allCases.count)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)

                    Text(viewModel.step == .store
                         ? LocalizedStringKey("Your store")
                         : LocalizedStringKey("Categories"))
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 8)

            // Proqres zolağı aşağıda olduğu kimi qalır
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
            AppButtonView(
                title: viewModel.step == .store ? LocalizedStringKey("Continue") : LocalizedStringKey("Finish"),
                isLoading: viewModel.isSaving,
                usesBrandGradient: true
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
