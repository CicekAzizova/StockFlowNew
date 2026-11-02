//
//  EndPoint.swift
//  StockFlow
//
//  Created by Cicek on 20.09.26.
//

import Foundation

protocol Endpoint {
    
    var path: String { get }
    var method: HttpMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var httpBody: Encodable? { get }
    var requiresAuthentication: Bool { get }
}

extension Endpoint {
    var baseURL: String {
        AppConfig.baseURL
    }
    
    var headers: [String: String]? {
        [
            HttpHeader.accept: Accept.json,
            HttpHeader.contentType: ContentType.json
        ]
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var httpBody: Encodable? {
        return nil
    }
    
    var requiresAuthentication: Bool {
        true
    }
}

extension Endpoint {
    func makeRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidUrl
        }
        
        components.path = components.path.appending(path)
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        headers?.forEach { key, value in
            if key == HttpHeader.contentType && httpBody == nil { return }
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let httpBody {
            do {
                let encodedBody = try JSONEncoder().encode(httpBody)
                request.httpBody = encodedBody
            } catch {
                throw NetworkError.encodingError
            }
        }
        return request
    }
}
