//
//  HTTPResponse.swift
//  InstaSaver
//
//  Created by somesh-8758 on 19/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public struct HTTPResponse<Success, Failure: Error> {
    public let urlResponse: URLResponse?
    public let data: Data?
    public let result: Result<Success, Failure>
    public var error: Failure? {return result.error}
    public var value: Success? {return result.value}
    public var httpURLResponse: HTTPURLResponse? {return urlResponse as? HTTPURLResponse}
    
    init(data: Data?, response: URLResponse?, result: Result<Success, Failure>) {
        self.urlResponse = response
        self.data = data
        self.result = result
    }
}

public extension Result {
    var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
    
    var value: Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}
