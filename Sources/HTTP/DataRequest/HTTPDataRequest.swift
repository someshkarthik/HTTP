//
//  HTTPDataRequest.swift
//  HTTP
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

final internal class HTTPDataRequest: HTTPRequest, Builder {
    var dataRequestDelegate: HTTPDataRequestDelegate = .init()
    
    var decodable: HTTPDecodable.Type?
    
    var dataCompletionHandler: HTTPDataResponseHandler?
    var stringCompletionHandler: HTTPStringResponseHandler?
    var jsonCompletionHandler: HTTPJSONResponseHandler?
    var decodingCompletionHandler: HTTPDecodableHandler?
    
    public static func builder() -> HTTPDataRequest {
        return .init()
    }
    
    @discardableResult
    public func build() -> HTTPDataRequest {
        
        dataRequestDelegate.delegate = self
        
        var urlRequest: URLRequest
        
        if let urlRequestConvertible = url as? URLRequestRepresentable {
            urlRequest = urlRequestConvertible.asURLRequest()
            task = session?.dataTask(with: urlRequest)
        } else {
            do {
                let _url = try url.asURl()
                urlRequest = URLRequest(url: _url)
            } catch {
                httpDataRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError)
                )
                return self
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        
        if !parameters.isEmpty {
            do { try urlRequest.url?.encode(withParameters: self.parameters) }
            catch {
                httpDataRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError)
                )
                return self
            }
        }
        
        for (key,value) in header {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        task = session?.dataTask(with: urlRequest)
        task?.resume()
        return self
    }
}

extension HTTPDataRequest: DataRequestDelegate {
    func httpDataRequestDelegate(_ progress: Progress) {
        progressHandler?(progress.httpProgress)
    }
    
    func httpDataRequestDelegate(finishedWithError error: ErrorResponse) {
        errorHandler?(error)
    }
    
    func httpDataRequestDelegate(finishedWithData data: DataResponse) {
        dispathResult(forResponse: data)
    }
}

extension HTTPDataRequest {
    private func dispathResult(forResponse response: DataResponse) {
        if self.dataCompletionHandler != nil {
            self.dataCompletionHandler?(response)
        }
        
        do {
            if self.stringCompletionHandler != nil {
                let stringResult = try response.stringSerialiser()
                self.stringCompletionHandler?(stringResult)
            }
            
            if self.jsonCompletionHandler != nil {
                let jsonResult = try response.jsonSerialiser()
                self.jsonCompletionHandler?(jsonResult)
            }
            
            if self.decodable != nil {
                NotificationCenter.default.post(name: NSNotification.Name("Decode"), object: (response,errorHandler))
            }
            
        } catch {
            errorHandler?(.init(data: response.data, response: response.urlResponse, result: error.httpError))
        }
        
    }
}
