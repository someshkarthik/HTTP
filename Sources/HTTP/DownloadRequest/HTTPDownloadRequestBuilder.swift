//
//  File.swift
//  
//
//  Created by somesh-8758 on 24/05/20.
//

import Foundation

public struct HTTPDownloadRequestBuilder: RequestBuilder {
    typealias CompletionHandler = HTTPDownloadResponseHandler
    public typealias HTTPDownloadFileDestination = (_ defaultDestinationURL: URL,_ response: HTTPURLResponse?) -> (targetURL: URL,options: HTTPDownloadRequestBuilder.DestinationFileOptions)
    
    
    internal var _url: URLRepresentable = URL(string: "com.nosuchurl.com")!
    internal var _parameters: HTTPParameters = [:]
    internal var _header: HTTPHeader = [:]
    internal var _requestMethod: HTTPMethod = .get
    internal var _progressHandler: HTTPProgressHandler?
    internal var _completionHandler: HTTPDownloadResponseHandler?
    private var _fileDestination: Self.HTTPDownloadFileDestination?
    internal var _errorHandler: HTTPErrorHandler?
    internal var _sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    
    public static func builder() -> HTTPDownloadRequestBuilder {
        return .init()
    }
    
    public func url(_ url: URLRepresentable) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    public func urlRequest(_ url: URLRequestRepresentable) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._url = url
        return mutable
    }
    
    public func header(_ header: HTTPHeader) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._header = header
        return mutable
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._requestMethod = requestMethod
        return mutable
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._parameters = parameters
        return mutable
    }
    
    public func sessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._sessionConfiguration = sessionConfiguration
        return mutable
    }
    
    public func fileDestination(_ fileDestination: @escaping Self.HTTPDownloadFileDestination) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._fileDestination = fileDestination
        return mutable
    }
    
    public func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._progressHandler = progressHandler
        return mutable
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDownloadResponseHandler) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._completionHandler = completionHandler
        return mutable
    }
    
    public func `catch`(_ errorHandler: @escaping HTTPErrorHandler) -> HTTPDownloadRequestBuilder {
        var mutable = self
        mutable._errorHandler = errorHandler
        return mutable
    }
    
    @discardableResult
    public func build() -> HTTPRequest {
        let request = HTTPDownloadRequest.builder()
        
        request.session = URLSession(configuration: _sessionConfiguration, delegate: request.downloadRequestDelegate, delegateQueue: nil)
        
        request._url = _url
        request._header = _header
        request._errorHandler = _errorHandler
        request._progressHandler = _progressHandler
        request._parameters = _parameters
        request._method = _requestMethod
        request._downloadCompletionHandler = _completionHandler
        
        request.downloadRequestDelegate.fileDestination = _fileDestination
        
        return request.build()
    }
}


public extension HTTPDownloadRequestBuilder {
    struct DestinationFileOptions: OptionSet {
        public typealias RawValue = Int
        public var rawValue: HTTPDownloadRequestBuilder.DestinationFileOptions.RawValue
        
        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
        
        public static var removeDuplicate = DestinationFileOptions(rawValue: 1<<0)
        public static var createIntermediateDirectories = DestinationFileOptions(rawValue: 1<<1)
    }
}
