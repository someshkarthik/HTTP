//
//  HTTPError.swift
//  InstaSaver
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

open class HTTPError: Error {
    public private(set) var localizedDescription: String
    public private(set) var type: Type
    public private(set) var errorCode: Int = 0
    
    convenience init() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        self.init(error: error)
    }
    
    init(error: Error) {
        localizedDescription = error.localizedDescription
        errorCode = error._code
        switch error._code {
        case NSURLErrorTimedOut:
            type = .timeOut
        case NSURLErrorNotConnectedToInternet,NSURLErrorNetworkConnectionLost:
            type = .noNetwork
        case NSURLErrorCancelled:
            type = .cancelled
        case NSURLErrorUnknown:
            type = .unknown
        case NSURLErrorCannotParseResponse,NSURLErrorCannotDecodeRawData,NSURLErrorCannotDecodeContentData:
            type = .dataParsing
        case NSURLErrorSecureConnectionFailed,
             NSURLErrorServerCertificateHasBadDate,
             NSURLErrorServerCertificateUntrusted,
             NSURLErrorServerCertificateHasUnknownRoot,
             NSURLErrorServerCertificateNotYetValid,
             NSURLErrorClientCertificateRejected,
             NSURLErrorClientCertificateRequired,
             NSURLErrorCannotLoadFromNetwork:
            type = .sslConnection
        case NSURLErrorZeroByteResource:
            type = .noData
        case NSURLErrorBadURL, NSURLErrorUnsupportedURL:
            type = .badURL
        case NSInputStreamError:
            type = .bufferStream
        case NSURLNotValidURLError:
            type = .invalidURL
        default:
            type = .unknown
        }
    }
    
    public static func dataParsingError() -> HTTPError {
        let userInfo = [NSLocalizedFailureErrorKey: "Data Parsing Error",
                        NSLocalizedFailureReasonErrorKey: "Data response from the server connot be converted to target type"]
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, userInfo: userInfo)
        return HTTPError(error: error)
    }
    
    public static func streamError() -> HTTPError {
        let error = NSError(domain: HTTPErrorDomain, code: NSInputStreamError, userInfo: nil)
        return HTTPError(error: error)
    }
    
    public static func invalidURl() -> HTTPError {
        let userInfo = [NSLocalizedFailureErrorKey: "Invalid URL",
                        NSLocalizedFailureReasonErrorKey: "Unable to form URL from the given value"]
        let error = NSError(domain: HTTPErrorDomain, code: NSURLNotValidURLError, userInfo: userInfo)
        return HTTPError(error: error)
    }
}

public extension HTTPError {
    enum `Type` {
        case noNetwork
        case timeOut
        case unknown
        case cancelled
        case dataParsing
        case autoToken
        case noData
        case sslConnection
        case badURL
        case bufferStream
        case invalidURL
    }
}

internal extension Error {
    var httpError: HTTPError {
        return HTTPError(error: self)
    }
}

public var HTTPErrorDomain = "com.httperror.domain"
public var NSInputStreamError: Int {return 12345}
public var NSURLNotValidURLError: Int {return 12346}
