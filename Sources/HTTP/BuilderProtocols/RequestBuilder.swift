//
//  File.swift
//  HTTP
//
//  Created by somesh-8758 on 25/05/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

internal protocol RequestBuilder: TaskBuilder {
    var _url: URLRepresentable {get set}
    var _parameters: HTTPParameters {get set}
    var _header: HTTPHeader {get set}
    var _requestMethod: HTTPMethod {get set}
    var _progressHandler: HTTPProgressHandler? {get set}
    var _completionHandler: CompletionHandler? {get set}
    var _sessionConfiguration: URLSessionConfiguration {get set}
    var _errorHandler: HTTPErrorHandler? {get set}
    
}
