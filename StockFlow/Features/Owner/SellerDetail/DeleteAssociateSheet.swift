//
//  DeleteAssociateSheet.swift
//  StockFlow
//
//  Created by Cicek on 05.11.26.
//

import SwiftUI

/// Satıcını silməzdən əvvəl göstərilən təsdiq paneli.
struct DeleteAssociateSheet: View {

    let associate: SellerResponse
    let salesCount: Int
    let onConfirm: () -> Void
    /// nil olsa (satıcı artıq deaktivdir), "deaktiv edin" xətti görünmür.
    let onDeactivate: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var contentHeight: CGFloat = 480

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.error)
                .frame(width: 56, height: 56)
                .background(Color.error.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                .padding(.top, 24)

            VStack(spacing: 8) {
                Text("Delete Sales Associate?")
                    .font(.title3.bold())
                    .foregroundStyle(Color.textPrimary)

                Text("\(associate.name) will no longer be able to sign in to this store. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            associateCard

            VStack(spacing: 10) {
                Button {
                    dismiss()
                    onConfirm()
                } label: {
                    Label("Yes, delete", systemImage: "trash")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.error, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.textSecondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }

            if let onDeactivate {
                VStack(spacing: 2) {
                    Text("To pause access temporarily")
                        .font(.footnote)
                        .foregroundStyle(Color.textSecondary)

                    Button {
                        dismiss()
                        onDeactivate()
                    } label: {
                        Text("Deactivate the account instead")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.brandTeal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            contentHeight = height
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(Color.surface)
    }

    private var associateCard: some View {
        HStack(spacing: 12) {
            SellerAvatar(associate: associate, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(associate.name) \(associate.surname)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("\(salesCount) sales · \(associate.phone)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.background, in: RoundedRectangle(cornerRadius: 14))
    }
}
