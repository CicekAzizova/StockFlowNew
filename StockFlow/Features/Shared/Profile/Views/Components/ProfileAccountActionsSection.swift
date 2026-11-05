//
//  ProfileAccountActionsSection.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//
import SwiftUI

/// Çıxış və Hesabı sil sətirləri. Hesabı sil yalnız owner üçündür.
struct ProfileAccountActionsSection: View {

    let user: User
    let onLogout: () -> Void
    let onDeleteAccount: () -> Void

    var body: some View {
        AppSectionView {
            Button(action: onLogout) {
                AppRowView(
                    icon: "rectangle.portrait.and.arrow.right",
                    tint: .red,
                    title: "Log Out",
                    titleColor: .red
                )
            }

            if user.role == .owner {
                Button(action: onDeleteAccount) {
                    AppRowView(
                        icon: "trash",
                        tint: .red,
                        title: "Delete Account",
                        titleColor: .red
                    )
                }
            }
        }
        .buttonStyle(.plain)
    }
}
