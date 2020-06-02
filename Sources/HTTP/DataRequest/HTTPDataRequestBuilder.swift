//
//  HTTPDataRequestBuilder.swift
//  HTTP
//
//  Created by somesh-8758 on 24/05/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public struct HTTPDataRequestBuilder: RequestBuilder, TaskBuilder {
    
    internal var _url: URLRepresentable = URL(string: "com.nosuchurl.com")!
    internal var _parameters: HTTPParameters = [:]
    internal var _header: HTTPHeader = [:]
    internal var _requestMethod: HTTPMethod = .get
    internal var _progressHandler: HTTPProgressHandler?
    internal var _completionHandler: HTTPDataResponseHandler?
    private var _jsonCompletionHandler: HTTPJSONResponseHandler?
    private var _stringCompletionHandler: HTTPStringResponseHandler?
    private var decodingCompletionHandler: HTTPDecodableHandler?
    internal var _errorHandler: HTTPErrorHandler?
    internal var decodable: HTTPDecodable.Type?
    
    internal var _sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    public static func builder() -> HTTPDataRequestBuilder {
        return HTTPDataRequestBuilder()
    }
    
    public func url(_ url: URLRepresentable) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    public func urlRequest(_ url: URLRequestRepresentable) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._parameters = parameters
        return mutable
    }
    
    public func header(_ header: HTTPHeader) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._header = header
        return mutable
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._requestMethod = requestMethod
        return mutable
    }
    
    public func sessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._sessionConfiguration = sessionConfiguration
        return mutable
    }
    
    public func decode<T: Decodable>(to decodable: T.Type, completion: @escaping (HTTPResponse<T>)->Void) -> HTTPDataRequestBuilder{
        var mutable = self
        mutable.decodable = decodable
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Decode"), object: nil, queue: nil) { (notification) in
            let object = notification.object as! (DataResponse,HTTPErrorHandler?)
            let dataResponse = object.0
            let errorHandler = object.1
            do {
                let result = try dataResponse.decode(to: decodable)
                completion(result)
            }catch {
                errorHandler?(.init(data: dataResponse.data, response: dataResponse.urlResponse, result: error.httpError))
            }
        }
        
        return mutable
    }
    
    public func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._progressHandler = progressHandler
        return mutable
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDataResponseHandler) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._completionHandler = completionHandler
        return mutable
    }
    
    public func stringResponse(_ completionHandler: @escaping HTTPStringResponseHandler) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._stringCompletionHandler = completionHandler
        return mutable
    }
    
    public func jsonResponse(_ completionHandler: @escaping HTTPJSONResponseHandler) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._jsonCompletionHandler = completionHandler
        return mutable
    }
    
    public func `catch`(_ errorHandler: @escaping HTTPErrorHandler) -> HTTPDataRequestBuilder {
        var mutable = self
        mutable._errorHandler = errorHandler
        return mutable
    }
    
    @discardableResult
    public func build() -> HTTPRequest {
        let request = HTTPDataRequest()
        request.session = URLSession(configuration: _sessionConfiguration, delegate: request.dataRequestDelegate, delegateQueue: nil)
        
        request._url = _url
        request._header = _header
        request._errorHandler = _errorHandler
        request._progressHandler = _progressHandler
        request._parameters = _parameters
        request._method = _requestMethod
        request.dataCompletionHandler = _completionHandler
        request.jsonCompletionHandler = _jsonCompletionHandler
        request.stringCompletionHandler = _stringCompletionHandler
        request.decodingCompletionHandler = decodingCompletionHandler
        request.decodable = decodable
        
        return request.build()
    }
}
