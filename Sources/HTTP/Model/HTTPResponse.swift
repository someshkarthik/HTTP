//
//  HTTPResponse.swift
//  HTTP
//
//  Created by somesh-8758 on 19/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public struct HTTPResponse<Result> {
    public let urlResponse: URLResponse?
    public var httpURLResponse: HTTPURLResponse? {urlResponse as? HTTPURLResponse}
    public let data: Data?
    public let value: Result
    init(data: Data?, response: URLResponse?,result: Result) {
        self.value = result
        self.data = data
        self.urlResponse = response
    }
}
