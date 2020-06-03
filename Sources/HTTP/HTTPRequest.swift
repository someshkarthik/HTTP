//
//  HTTPRequest.swift
//  HTTP
//
//  Created by somesh-8758 on 20/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public class HTTPRequest: NSObject {
    var url: URLRepresentable = URL(string: "com.nosuchurl.com")!
    var method: HTTPMethod = .get
    var header: HTTPHeader = [:]
    var parameters: HTTPParameters = [:]
    var sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    var session: URLSession?
    var task: URLSessionTask?
    var progressHandler: HTTPProgressHandler?
    var errorHandler: HTTPErrorHandler?

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
