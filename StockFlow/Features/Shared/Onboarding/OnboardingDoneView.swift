//
//  OnboardingDoneView.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

struct OnboardingDoneView: View {

    let viewModel: OnboardingViewModel

    @Environment(CatalogStore.self) private var catalogStore
    @Environment(LanguageManager.self) private var languageManager
    @State private var appeared = false

    private var businessTypes: String {
        let names = viewModel.selectedCategories.compactMap {
            catalogStore.category(code: $0)?.names.value(for: languageManager.language)
        }
        return names.isEmpty ? "—" : names.joined(separator: ", ")
    }

    private var categoriesCount: Int {
        viewModel.selectedSubcategories.count + viewModel.customDrafts.count
    }

    private var storeCount: Int {
        viewModel.locations.filter { $0.kind == .store }.count
    }

    private var warehouseCount: Int {
        viewModel.locations.filter { $0.kind == .warehouse }.count
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                hero

                summaryCard
                    .padding(.horizontal, 24)
                    .padding(.top, -44)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    .zIndex(1)

                ScrollView {
                    nextSteps
                        .padding(24)
                }

                AppButtonView(
                    title: "Go to dashboard",
                    isLoading: false,
                    usesBrandGradient: true
                ) {
                    viewModel.enterApp()
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(Color.background)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }

    // MARK: - Yuxarı hissə

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 112, height: 112)
                Circle()
                    .fill(.white)
                    .frame(width: 84, height: 84)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .padding(.bottom, 8)

            Text("Your store is ready!")
                .font(.inter(.extraBold, size: 26))
                .foregroundStyle(.white)

            Text("\(viewModel.storeName) was created successfully")
                .font(.inter(.regular, size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 76)
        .frame(maxWidth: .infinity)
        .overlay { confetti }
        .brandHeaderBackground()
    }

    private var confetti: some View {
        ZStack {
            confettiPiece(.orange, x: -130, y: -60, angle: 20)
            confettiPiece(.white, x: 125, y: -70, angle: -15)
            confettiPiece(.pink, x: 150, y: -20, angle: 35)
            confettiPiece(.yellow, x: -105, y: -10, angle: -30)
            confettiPiece(.mint, x: -85, y: -95, angle: 45)
        }
        .opacity(appeared ? 1 : 0)
    }

    private func confettiPiece(_ color: Color, x: CGFloat, y: CGFloat, angle: Double) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(angle))
            .offset(x: x, y: y)
    }

    // MARK: - Xülasə

    private var summaryCard: some View {
        VStack(spacing: 0) {
            summaryRow("Business type") {
                Text(verbatim: businessTypes)
            }
            Divider()
            summaryRow("Categories") {
                if categoriesCount == 0 {
                    Text("All")
                } else {
                    Text("\(categoriesCount) categories")
                }
            }
            Divider()
            summaryRow("Locations") {
                Text("\(storeCount) stores · \(warehouseCount) warehouses")
            }
            Divider()
            summaryRow("Currency") {
                Text(verbatim: viewModel.currency.rawValue)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow<Value: View>(
        _ title: LocalizedStringKey,
        @ViewBuilder value: () -> Value
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .foregroundStyle(.textSecondary)
            Spacer(minLength: 8)
            value()
                .fontWeight(.bold)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .font(.inter(.regular, size: 14))
        .padding(.vertical, 14)
    }

    // MARK: - Növbəti addımlar

    private var nextSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEXT STEPS")
                .font(.inter(.bold, size: 12))
                .foregroundStyle(.textSecondary)

            VStack(spacing: 0) {
                stepRow(1, "Add your first product", "Scan a barcode or enter it manually")
                Divider()
                stepRow(2, "Add a seller", "Create accounts for your team")
                Divider()
                stepRow(3, "Customize your account", "Logo, phone and low stock alerts")
            }
            .padding(.horizontal, 16)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func stepRow(_ number: Int, _ title: LocalizedStringKey, _ subtitle: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Text(verbatim: "\(number)")
                .font(.inter(.bold, size: 13))
                .foregroundStyle(.textSecondary)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle().stroke(Color.gray.opacity(0.35), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.textPrimary)
                Text(subtitle)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
    }
}
