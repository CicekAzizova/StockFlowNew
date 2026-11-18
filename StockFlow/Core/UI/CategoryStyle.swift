//
//  CategoryStyle.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

/// Əsas kateqoriya kodunun (food, clothing...) rəngi və ikonu.
enum CategoryStyle {

    static func tint(for code: String) -> Color {
        switch code {
        case "food": Color.brandGreen
        case "clothing": Color.purple
        case "footwear_bags": Color.indigo
        case "electronics": Color.blue
        case "home": Color.teal
        case "beauty": Color.pink
        case "kids": Color.orange
        case "books": Color(red: 0.85, green: 0.45, blue: 0.2)
        case "auto": Color.red
        case "construction": Color.yellow
        case "sports": Color.mint
        default: Color.gray
        }
    }

    static func icon(for code: String) -> String {
        switch code {
        case "food": "cart"
        case "clothing": "tshirt"
        case "footwear_bags": "bag"
        case "electronics": "iphone"
        case "home": "house"
        case "beauty": "sparkles"
        case "kids": "teddybear"
        case "books": "book"
        case "auto": "car"
        case "construction": "hammer"
        case "sports": "figure.run"
        default: "shippingbox"
        }
    }
}
