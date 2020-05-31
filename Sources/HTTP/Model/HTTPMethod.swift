//
//  HTTPMethod.swift
//  HTTP
//
//  Created by somesh-8758 on 19/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

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

public typealias HTTPHeader = [String: String]
public typealias HTTPParameters = [String: String]
public typealias HTTPDecodable = Decodable

//Data Models
public typealias JSON = Dictionary<AnyHashable, Any>
public typealias DataResponse = HTTPResponse<Data>
public typealias DataResult = Data
public typealias JSONResponse = HTTPResponse<JSON>
public typealias JSONResult = JSON
public typealias DownloadResponse = HTTPResponse<URL>
public typealias DownloadResult = URL
public typealias StringResponse = HTTPResponse<String>
public typealias StringResult = String
public typealias DecodingResponse = HTTPResponse<HTTPDecodable>
public typealias ErrorResponse = HTTPResponse<HTTPError>

//Handlers
public typealias HTTPDataResponseHandler = (DataResponse) -> Void
public typealias HTTPStringResponseHandler = (StringResponse) -> Void
public typealias HTTPDownloadResponseHandler = (DownloadResponse) -> Void
public typealias HTTPJSONResponseHandler = (JSONResponse) -> Void
public typealias HTTPProgressHandler = (Progress) -> Void
public typealias HTTPMultiPartDataHandler = ()->(MultiPartData)
public typealias HTTPDecodableHandler = (DecodingResponse)->Void
public typealias HTTPErrorHandler = (ErrorResponse)->Void

/*
final public class HTTPRequestBuilder {
    
    private var sessionConfiguration: URLSessionConfiguration = {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 30
        defaultConfiguration.allowsCellularAccess = true
        return defaultConfiguration
    }()
    
    public init() { }
    
    public func sessionConfiguation(_ sessionConfiguration: URLSessionConfiguration) -> HTTPRequestBuilder {
        self.sessionConfiguration = sessionConfiguration
        return self
    }
    
    //MARK: BUILDER FUNCTIONS
    /*
    public func buildWithDataRequest() -> HTTPDataRequest {
        let dataDelegate = HTTPDataRequestDelegate()
        let request = HTTPDataRequest.builder()
            .setSession(URLSession(configuration: sessionConfiguration, delegate: dataDelegate, delegateQueue: nil))
        dataDelegate.delegate = request
        return request
    }
    */
    
    /*
    public func buildWithDownloadRequest() -> HTTPDownloadRequest {
        let request = HTTPDownloadRequest.builder()
        let session = URLSession(configuration: sessionConfiguration, delegate: request, delegateQueue: nil)
        return request.setSession(session)
    }
    */
    
    public func buildWithUploadRequest() -> HTTPUploadRequest {
        let request = HTTPUploadRequest.builder()
        let session = URLSession(configuration: sessionConfiguration, delegate: request, delegateQueue: nil)
        return request.setSession(session)
    }
}
*/
