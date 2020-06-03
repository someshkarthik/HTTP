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

extension RequestBuilder where Self == Buildable {
    func url(_ url: URLRepresentable) -> Buildable {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    func urlRequest(_ url: URLRequestRepresentable) -> Buildable {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    func header(_ header: HTTPHeader) -> Buildable {
        var mutable = self
        mutable._header = header
        return mutable
    }
    
    func requestMethod(_ requestMethod: HTTPMethod) -> Buildable {
        var mutable = self
        mutable._requestMethod = requestMethod
        return mutable
    }
    
    func queryParameters(_ parameters: HTTPParameters) -> Buildable {
        var mutable = self
        mutable._parameters = parameters
        return mutable
    }
    
    func sessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Buildable {
        var mutable = self
        mutable._sessionConfiguration = sessionConfiguration
        return mutable
    }
    
    func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> Buildable {
        var mutable = self
        mutable._progressHandler = progressHandler
        return mutable
    }
    
    func `catch`(_ errorHandler: @escaping HTTPErrorHandler) -> Buildable {
        var mutable = self
        mutable._errorHandler = errorHandler
        return mutable
    }
}
