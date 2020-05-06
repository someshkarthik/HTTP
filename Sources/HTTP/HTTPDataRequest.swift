//
//  HTTPDataRequest.swift
//  InstaSaver
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

open class HTTPDataRequest: HTTPRequest, TaskBuilder {
    
    public typealias CompletionHandler = HTTPDataResponseHandler
    public typealias RequestBuilder = HTTPDataRequest
    
    private var buffer: Data = Data()
    private var contentLength: Int64 = 0
    
    private var _dataCompletionHandler: HTTPDataResponseHandler?
    private var _stringCompletionHandler: HTTPStringResponseHandler?
    private var _jsonCompletionHandler: HTTPJSONResponseHandler?
    
    public static func builder() -> HTTPDataRequest {
        let request = HTTPDataRequest()
        return request
    }
    
    public func url(_ url: URLConvertible) -> HTTPDataRequest {
        self._url = url
        return self
    }
    
    public func urlRequest(_ url: URLRequestConvertible) -> HTTPDataRequest {
        self._url = url
        return self
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPDataRequest {
        self._parameters = parameters
        return self
    }
    
    public func header(_ header: HTTPHeader) -> HTTPDataRequest {
        self._header = header
        return self
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPDataRequest {
        self._method = requestMethod
        return self
    }
    
    public func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> HTTPDataRequest {
        self._progressHandler = progressHandler
        return self
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDataResponseHandler) -> HTTPDataRequest {
        self._dataCompletionHandler = completionHandler
        return self
    }
    
    public func stringCompletionHandler(_ completionHandler: @escaping HTTPStringResponseHandler) -> HTTPDataRequest {
        self._stringCompletionHandler = completionHandler
        return self
    }
    
    public func jsonCompletionHandler(_ completionHandler: @escaping HTTPJSONResponseHandler) -> HTTPDataRequest {
        self._jsonCompletionHandler = completionHandler
        return self
    }
    
    @discardableResult
    public func build() -> RequestBuilder {
        var urlRequest: URLRequest
        
        if let urlRequestConvertible = _url as? URLRequestConvertible {
            urlRequest = urlRequestConvertible.asURLRequest()
            task = session?.dataTask(with: urlRequest)
        } else {
            do {
                let url = try _url.asURl()
                urlRequest = URLRequest(url: url)
            } catch { encodeResponse(for: error, response: nil); return self}
        }
        
        urlRequest.timeoutInterval = sessionConfiguration.timeoutIntervalForRequest
        urlRequest.allowsCellularAccess = sessionConfiguration.allowsCellularAccess
        
        if let method = _method?.rawValue {
            urlRequest.httpMethod = method
        }
        
        if !_parameters.isEmpty {
            do { try urlRequest.url?.encode(withParameters: self._parameters) }
            catch { encodeResponse(for: error, response: nil); return self }
        }
        
        for (key,value) in _header {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        task = session?.dataTask(with: urlRequest)
        task?.resume()
        return self
    }
}

extension HTTPDataRequest: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        contentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        let progress = dataTask.progress
        progress.completedUnitCount = Int64(buffer.count)
        progress.totalUnitCount = contentLength
        _progressHandler?(progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        encodeResponse(for: error, response: task.response)
    }
    
    private func encodeResponse(for error: Error?, response: URLResponse?) {
        let result: DataResult
        if let error = error {
            result = .failure(error.httpError)
        } else {
            result = .success(buffer)
        }
        let response: DataResponse = .init(data: buffer, response: response, result: result)
        dispathResult(forResponse: response)
    }
    
    private func dispathResult(forResponse response: DataResponse) {
            if self._dataCompletionHandler != nil {
                self._dataCompletionHandler?(response)
            }
            
            if self._stringCompletionHandler != nil {
                self._stringCompletionHandler?(response.stringSerialiser())
            }
            
            if self._jsonCompletionHandler != nil {
                self._jsonCompletionHandler?(response.jsonSerialiser())
            }
    }
}
