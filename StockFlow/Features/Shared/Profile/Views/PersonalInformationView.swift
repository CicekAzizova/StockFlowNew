//
//  PersonalInformationView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

struct PersonalInformationView: View {

    let user: User
    /// Yalnız owner üçün verilir. nil olsa, "Edit" düyməsi görünmür.
    var onEditTap: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                AppSectionView {
                    infoRow(icon: "person", tint: .blue, title: "First name", value: user.name)
                    infoRow(icon: "person.text.rectangle", tint: .brandTeal, title: "Last name", value: user.surname ?? "")
                    infoRow(icon: "envelope", tint: .brandCoral, title: "Email", value: user.email)
                    infoRow(icon: "phone", tint: .brandGreen, title: "Phone", value: user.phone ?? "-")
                    roleRow
                }
                .padding(16)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onEditTap {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit", action: onEditTap)
                }
            }
        }
    }

    // MARK: - Rows

    private func infoRow(
        icon: String,
        tint: Color,
        title: LocalizedStringKey,
        value: String
    ) -> some View {
        AppRowView(icon: icon, tint: tint, title: title) {
            Text(verbatim: value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var roleRow: some View {
        AppRowView(icon: "star", tint: .orange, title: "Role") {
            Text(user.role.displayName)
                .foregroundStyle(.secondary)
        }
    }
}
