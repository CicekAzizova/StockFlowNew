//
//  CatalogResponse.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//

struct CatalogResponse: Decodable {
    let categories: [CatalogCategory]
}

struct CatalogCategory: Decodable, Identifiable {
    let code: String
    let names: LocalizedNames
    let subcategories: [CatalogSubcategory]
    var id: String { code }
}

struct CatalogSubcategory: Decodable, Identifiable {
    let code: String
    let names: LocalizedNames
    var id: String { code }
}

struct LocalizedNames: Decodable {
    let en: String
    let az: String
    let ru: String
    let tr: String
}

extension LocalizedNames {
    func value(for language: AppLanguage) -> String {
        switch language {
        case .english: en
        case .azerbaijani: az
        case .russian: ru
        case .turkish: tr
        }
    }
}
