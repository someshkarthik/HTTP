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
public typealias HTTPProgressHandler = (HTTPProgress) -> Void
public typealias HTTPMultiPartDataHandler = ()->(MultiPartData)
public typealias HTTPDecodableHandler = (DecodingResponse)->Void
public typealias HTTPErrorHandler = (ErrorResponse)->Void
