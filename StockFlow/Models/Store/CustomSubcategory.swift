//
//  CustomSubcategory.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

/// Mağazanın öz alt kateqoriyası (serverdən gəlir).
struct CustomSubcategory: Codable, Identifiable, Hashable {
    let code: String
    let main: String
    var name: String
    var id: String { code }
}

/// Serverə göndərilən forma: kod yoxdursa, yeni kateqoriyadır.
struct CustomSubcategoryInput: Encodable {
    var code: String? = nil
    let main: String
    let name: String
}
