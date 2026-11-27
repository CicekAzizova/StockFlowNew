//
//  WelcomeView.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct WelcomeSlide: Identifiable {
    enum Illustration {
        case scan, stock, panel
    }

    let id: Int
    let illustration: Illustration
    let title: LocalizedStringKey
    let text: LocalizedStringKey
}

struct WelcomeView: View {

    let onRegister: () -> Void
    let onSignIn: () -> Void

    @State private var page = 0

    private let slides: [WelcomeSlide] = [
        WelcomeSlide(
            id: 0,
            illustration: .scan,
            title: "Scan the barcode, sell in seconds",
            text: "Find the product with the camera, add it to the cart and finish the sale with one tap."
        ),
        WelcomeSlide(
            id: 1,
            illustration: .stock,
            title: "Stock and team under control",
            text: "Track stock in every location, get alerts about low products and manage your sellers."
        ),
        WelcomeSlide(
            id: 2,
            illustration: .panel,
            title: "Manage your store from your phone",
            text: "Products, stock and sales in one place. No paper or Excel sheets needed."
        )
    ]

    private var isLastPage: Bool {
        page == slides.count - 1
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBar

                TabView(selection: $page) {
                    ForEach(slides) { slide in
                        WelcomeSlideView(slide: slide)
                            .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots
                    .padding(.bottom, 24)

                buttons
            }
        }
    }

    // MARK: - Fon

    private var background: some View {
        LinearGradient(
            stops: [
                .init(color: .brandDark, location: 0),
                .init(color: .brandTeal, location: 0.6),
                .init(color: .brandGreen, location: 1)
            ],
            startPoint: UnitPoint(x: 0.14, y: -0.18),
            endPoint: UnitPoint(x: 0.86, y: 1.18)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 260, height: 260)
                .offset(x: 70, y: -20)
        }
        .ignoresSafeArea()
    }

    // MARK: - Yuxarı panel

    private var topBar: some View {
        HStack(spacing: 10) {
            BrandHeaderIcon(systemImage: "chart.line.uptrend.xyaxis")

            Text(verbatim: AppInfo.name)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            LanguageMenuButton()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Nöqtələr

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(slides) { slide in
                Capsule()
                    .fill(.white.opacity(slide.id == page ? 1 : 0.35))
                    .frame(width: slide.id == page ? 28 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: page)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    // MARK: - Düymələr

    private var buttons: some View {
        VStack(spacing: 12) {
            Button {
                if isLastPage {
                    onRegister()
                } else {
                    withAnimation { page += 1 }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(isLastPage ? LocalizedStringKey("Create account") : LocalizedStringKey("Next"))
                    Image(systemName: "arrow.right")
                }
                .font(.inter(.bold, size: 16))
                .foregroundStyle(Color.brandTeal)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button(action: onSignIn) {
                Text(isLastPage ? LocalizedStringKey("I have an account · Sign in") : LocalizedStringKey("I already have an account"))
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Bir səhifə

private struct WelcomeSlideView: View {

    let slide: WelcomeSlide

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer(minLength: 0)

            illustration
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            Text(slide.title)
                .font(.inter(.extraBold, size: 30))
                .foregroundStyle(.white)

            Text(slide.text)
                .font(.inter(.regular, size: 16))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private var illustration: some View {
        switch slide.illustration {
        case .scan:
            WelcomeScanIllustration()
        case .stock:
            WelcomeStockIllustration()
        case .panel:
            WelcomePanelIllustration()
        }
    }
}

#Preview {
    WelcomeView(onRegister: {}, onSignIn: {})
        .environment(LanguageManager())
}
