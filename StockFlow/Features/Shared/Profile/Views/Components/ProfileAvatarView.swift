//
//  ProfileAvatarView.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

struct ProfileAvatarView: View {

    let name: String
    let imageUrl: String?
    var size: CGFloat = 76
    var isLoading = false

    private var cornerRadius: CGFloat { size * 0.26 }

    private var initial: String {
        name.trimmed.first.map { String($0).uppercased() } ?? "?"
    }

    var body: some View {
        ZStack {
            if imageUrl != nil {
                RemoteImageView(
                    imageUrl: imageUrl,
                    width: size,
                    height: size,
                    cornerRadius: cornerRadius
                )
            } else {
                initialView
            }
        }
        .frame(width: size, height: size)
        .overlay {
            if isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.black.opacity(0.35))
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }

    private var initialView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brandCoral.opacity(0.85), Color.brandCoral],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(initial)
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundStyle(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
