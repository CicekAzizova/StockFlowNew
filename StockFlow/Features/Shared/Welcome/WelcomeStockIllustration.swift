//
//  WelcomeStockIllustration.swift
//  StockFlow
//
//  Created by Cicek on 16.11.26.
//

import SwiftUI

struct WelcomeStockIllustration: View {

    var body: some View {
        ZStack {
            stockCard
                .rotationEffect(.degrees(-3))
                .offset(x: -8, y: -92)

            notificationCard
                .rotationEffect(.degrees(4))
                .offset(x: 40, y: 25)

            teamCard
                .rotationEffect(.degrees(-2))
                .offset(x: -26, y: 106)
        }
        .frame(height: 340)
    }

    // MARK: - Qalıq kartı

    private var stockCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Watch")
                    .font(.inter(.bold, size: 15))
                    .foregroundStyle(Color.brandDark)

                Spacer(minLength: 0)

                Text("Critical")
                    .font(.inter(.bold, size: 11))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
            }

            stockRow(name: "Main store", count: "2", level: 0.12, color: .red)
            stockRow(name: "Branch", count: "9", level: 0.45, color: .orange)
            stockRow(name: "Warehouse", count: "48", level: 0.9, color: Color.brandGreen)
        }
        .padding(14)
        .frame(width: 280)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func stockRow(name: LocalizedStringKey, count: String, level: CGFloat, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(width: 84, alignment: .leading)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))

                GeometryReader { proxy in
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * level)
                }
            }
            .frame(height: 6)

            Text(verbatim: count)
                .font(.inter(.bold, size: 13))
                .foregroundStyle(Color.brandDark)
                .frame(width: 28, alignment: .trailing)
        }
    }

    // MARK: - Bildiriş kartı

    private var notificationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 18))
                .foregroundStyle(.orange)
                .frame(width: 40, height: 40)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Notification · now")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text("Headphones running")
                    .font(.inter(.bold, size: 14))
                    .foregroundStyle(Color.brandDark)
                Text("low · 5 pcs")
                    .font(.inter(.bold, size: 12))
                    .foregroundStyle(Color.brandCoral)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 250)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Komanda kartı

    private var teamCard: some View {
        HStack(spacing: 12) {
            HStack(spacing: -8) {
                avatar("Ç", color: .orange)
                avatar("RM", color: .blue)
                avatar("LH", color: .purple)
                avatar("TQ", color: Color.brandTeal)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Team")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text("4 sellers · 2 online")
                    .font(.inter(.bold, size: 14))
                    .foregroundStyle(Color.brandDark)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 280)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func avatar(_ initials: String, color: Color) -> some View {
        Text(verbatim: initials)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
    }
}

#Preview {
    ZStack {
        Color.brandTeal.ignoresSafeArea()
        WelcomeStockIllustration()
    }
}
