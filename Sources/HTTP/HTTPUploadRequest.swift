//
//  HTTPUploadRequest.swift
//  InstaSaver
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public enum HTTPFileUploader {
    case data(Data)
    case url(URL)
}

open class HTTPUploadRequest: HTTPRequest, TaskBuilder {
    
    public typealias CompletionHandler = HTTPDataResponseHandler
    public typealias RequestBuilder = HTTPUploadRequest
    
    private var _fileUploader: HTTPFileUploader?
    private var _mutltiPartDataHandler: HTTPMultiPartDataHandler?
    private var _dataCompletionHandler: HTTPDataResponseHandler?

    public static func builder() -> HTTPUploadRequest {
        let request = RequestBuilder()
        return request
    }
    
    public func url(_ url: URLConvertible) -> HTTPUploadRequest {
        self._url = url
        return self
    }
    
    public func urlRequest(_ url: URLRequestConvertible) -> HTTPUploadRequest {
        self._url = url
        return self
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPUploadRequest {
        self._parameters = parameters
        return self
    }
    
    public func header(_ header: HTTPHeader) -> HTTPUploadRequest {
        self._header = header
        return self
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPUploadRequest {
        self._method = requestMethod
        return self
    }
    
    public func multiPartDataHandler(_ mutltiPartDataHandler: @escaping HTTPMultiPartDataHandler) -> HTTPUploadRequest{
        self._mutltiPartDataHandler = mutltiPartDataHandler
        return self
    }
    
    func fileUploader(_ fileUploader: HTTPFileUploader) -> HTTPUploadRequest {
        self._fileUploader = fileUploader
        return self
    }
    
    public func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> HTTPUploadRequest {
        self._progressHandler = progressHandler
        return self
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDataResponseHandler) -> HTTPUploadRequest {
        self._dataCompletionHandler = completionHandler
        return self
    }
    
    public func build() -> RequestBuilder {
        var multiPartData = _mutltiPartDataHandler?()
        var dataToUpload: Data
        switch _fileUploader {
        case let .data(data):
            dataToUpload = data
        case let .url(fileUrl):
            dataToUpload = (try? Data(contentsOf: fileUrl)) ?? Data()
        default:
            dataToUpload = Data()
            break
        }
        do {
            var urlRequest = URLRequest(url: try _url.asURl())
            urlRequest.httpMethod = _method!.rawValue
            urlRequest.httpBody = try multiPartData?.encode()
            _header["Connection"] = "Keep-Alive"
            _header["Content-Type"] = "multipart/form-data"
            urlRequest.allHTTPHeaderFields = _header
            task = session?.uploadTask(with: urlRequest, from: dataToUpload)
            task?.resume()
        }catch {
            
        }
        
        return self
    }

}



extension HTTPUploadRequest: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
       // progressHandler?(Float(totalBytesSent)/Float(totalBytesExpectedToSend))
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
}
