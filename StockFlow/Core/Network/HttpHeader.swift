//
//  HttpHeader.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

enum HttpHeader {
    static let accept = "Accept"
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let locationId = "X-Location-Id"
}

enum Accept {
    static let json = "application/json"
}

enum ContentType {
    static let json = "application/json"
}
