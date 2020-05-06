//
//  HTTPRequest.swift
//  InstaSaver
//
//  Created by somesh-8758 on 20/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation
public typealias HTTPHeader = [String: String]
public typealias HTTPParameters = [String: String]

public protocol TaskBuilder: Builder {
    associatedtype CompletionHandler
    
    func url(_ url: URLConvertible) -> RequestBuilder
    func urlRequest(_ url: URLRequestConvertible) -> RequestBuilder
    func header(_ header: HTTPHeader) -> RequestBuilder
    func requestMethod(_ requestMethod: HTTPMethod) -> RequestBuilder
    func queryParameters(_ parameters: HTTPParameters) -> RequestBuilder
    func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> RequestBuilder
    func completionHandler(_ completionHandler: CompletionHandler) -> RequestBuilder
}

open class HTTPRequest: NSObject {
    var _url: URLConvertible = URL(string: "com.nosuchurl.com")!
    var _method: HTTPMethod? = .get
    var _header: HTTPHeader = [:]
    var _parameters: HTTPParameters = [:]
    var sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    var backgroundSessionConfiguration: URLSessionConfiguration = {
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "HTTPRequest.Session.sessionConfigurstion")
        backgroundSessionConfiguration.httpMaximumConnectionsPerHost = 1
        backgroundSessionConfiguration.shouldUseExtendedBackgroundIdleMode = true
        return backgroundSessionConfiguration
    }()

    var session: URLSession?
    var task: URLSessionTask?
    var _progressHandler: HTTPProgressHandler?
    
    func setSession(_ session: URLSession) -> Self {
        self.session = session
        return self
    }

    func resume() {
        task?.resume()
    }
    
    func suspend() {
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}
