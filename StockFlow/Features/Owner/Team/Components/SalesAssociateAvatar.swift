//
//  SalesAssociateAvatar.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//
import SwiftUI

struct SalesAssociateAvatar: View {

    let associate: SalesAssociateResponse
    var size: CGFloat = 44

    private static let colors: [Color] = [.blue, .brandTeal, .brandCoral, .purple, .brandGreen]

    private var cornerRadius: CGFloat { size * 0.3 }

    var body: some View {
        if let avatarUrl = associate.avatarUrl, !avatarUrl.isEmpty {
            RemoteImageView(
                imageUrl: avatarUrl,
                width: size,
                height: size,
                cornerRadius: cornerRadius
            )
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        Text("\(associate.name.prefix(1))\(associate.surname.prefix(1))".uppercased())
            .font(.system(size: size * 0.36, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Self.colors[associate.id % Self.colors.count])
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
