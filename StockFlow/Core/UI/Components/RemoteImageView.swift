//
//  RemoteImageView.swift
//  StockFlow
//
//  Created by Cicek on 02.10.26.
//


import SwiftUI
import SDWebImageSwiftUI

struct RemoteImageView: View {
    let imageUrl: String?
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat = 10

    private var validURL: URL? {
        guard let imageUrl else { return nil }

        let trimmedURL = imageUrl.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanURL: String

        if trimmedURL.hasPrefix("["),
           let openingParenthesis = trimmedURL.firstIndex(of: "("),
           let closingParenthesis = trimmedURL.lastIndex(of: ")"),
           openingParenthesis < closingParenthesis {
            cleanURL = String(
                trimmedURL[
                    trimmedURL.index(after: openingParenthesis)..<closingParenthesis
                ]
            )
        } else {
            cleanURL = trimmedURL
        }

        return AppConfig.imageURL(from: cleanURL)
    }

    var body: some View {
        
        WebImage(url: validURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            placeholder
        }
        .indicator(.activity)
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 22))
            .foregroundStyle(.secondary)
            .frame(width: width, height: height)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
