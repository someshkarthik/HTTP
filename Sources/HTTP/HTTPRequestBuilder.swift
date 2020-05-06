//
//  HTTPRequestBuilder.swift
//  InstaSaver
//
//  Created by somesh-8758 on 19/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public protocol Builder {
    associatedtype RequestBuilder
    static func builder() -> RequestBuilder
    func build() -> RequestBuilder
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

//Data Models
public typealias JSON = Dictionary<AnyHashable, Any>
public typealias DataResponse = HTTPResponse<Data, HTTPError>
public typealias DataResult = Result<Data, HTTPError>
public typealias JSONResponse = HTTPResponse<JSON, HTTPError>
public typealias JSONResult = Result<JSON, HTTPError>
public typealias DownloadResponse = HTTPResponse<URL, HTTPError>
public typealias DownloadResult = Result<URL, HTTPError>
public typealias StringResponse = HTTPResponse<String, HTTPError>
public typealias StringResult = Result<String, HTTPError>

//Handlers
public typealias HTTPDataResponseHandler = (DataResponse) -> Void
public typealias HTTPStringResponseHandler = (StringResponse) -> Void
public typealias HTTPDownloadResponseHandler = (DownloadResponse) -> Void
public typealias HTTPJSONResponseHandler = (JSONResponse) -> Void
public typealias HTTPProgressHandler = (Progress) -> Void
public typealias HTTPMultiPartDataHandler = ()->(MultiPartData)

public class HTTPRequestBuilder: NSObject {
    
    private var sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    public override init() { }
    
    public func sessionConfiguation(_ sessionConfiguration: URLSessionConfiguration) -> HTTPRequestBuilder {
        self.sessionConfiguration = sessionConfiguration
        return self
    }
    
    //MARK: BUILDER FUNCTIONS
    public func buildWithDataRequest() -> HTTPDataRequest {
        let request = HTTPDataRequest.builder()
        let session = URLSession(configuration: sessionConfiguration, delegate: request, delegateQueue: nil)
        return request.setSession(session)
    }
    
    public func buildWithDownloadRequest() -> HTTPDownloadRequest {
        let request = HTTPDownloadRequest.builder()
        let session = URLSession(configuration: sessionConfiguration, delegate: request, delegateQueue: nil)
        return request.setSession(session)
    }
    
    public func buildWithUploadRequest() -> HTTPUploadRequest {
        let request = HTTPUploadRequest.builder()
        let session = URLSession(configuration: sessionConfiguration, delegate: request, delegateQueue: nil)
        return request.setSession(session)
    }
}
