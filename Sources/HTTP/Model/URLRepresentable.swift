//
//  URLRepresentable.swift
//  HTTP
//
//  Created by somesh-8758 on 23/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public protocol URLRepresentable {
    func asURl() throws -> URL
}

extension URL: URLRepresentable {
    public func asURl() throws -> URL {
        return self
    }
}

extension Optional: URLRepresentable where Wrapped == URL {
    public func asURl() throws -> URL {
        if let url = self {
            return url
        }
        throw HTTPError.invalidURl()
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

extension URLComponents: URLRepresentable {
    public func asURl() throws -> URL {
        if let url = url {
            return url
        }
        throw HTTPError.invalidURl()
    }
}

public protocol URLRequestRepresentable: URLRepresentable {
    func asURLRequest() -> URLRequest
}

extension URLRequest: URLRequestRepresentable {
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

extension String: URLRepresentable {
    public func asURl() throws -> URL {
        if let url = URL(string: self) {
            return url
        }
        throw HTTPError.invalidURl()
    }
}
