//
//  AppConfig.swift
//  StockFlow
//
//  Created by Cicek on 12.10.26.
//
import Foundation

enum AppConfig {
    static let baseURL = "https://stockflowbackendnew-api.onrender.com"
}
extension AppConfig {
    static func imageURL(from string: String) -> URL? {
        if string.hasPrefix("/") {
            return URL(string: baseURL + string)
        }
        return URL(string: string)
    }
}
