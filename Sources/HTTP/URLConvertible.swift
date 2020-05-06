//
//  URLConvertible.swift
//  InstaSaver
//
//  Created by somesh-8758 on 23/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public protocol URLConvertible {
    func asURl() throws -> URL
}

extension URL: URLConvertible {
    public func asURl() throws -> URL {
        return self
    }
}

public extension URL {
    mutating func encode(withParameters params: HTTPParameters) throws {
        guard var components = URLComponents(string: absoluteString) else {throw HTTPError.invalidURl()}
        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: params.map{URLQueryItem(name: $0.key, value: $0.value)})
        components.queryItems = queryItems
        self = try components.asURl()
    }
}

extension URLComponents: URLConvertible {
    public func asURl() throws -> URL {
        if let url = url {
            return url
        }
        throw HTTPError.invalidURl()
    }
}

public protocol URLRequestConvertible: URLConvertible {
    func asURLRequest() -> URLRequest
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() -> URLRequest {
        return self
    }
    
    public func asURl() throws -> URL {
        if let url = url {
            return url
        }
        throw HTTPError.invalidURl()
    }
}
