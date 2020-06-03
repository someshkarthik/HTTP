//
//  HTTPUploadRequest.swift
//  HTTP
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public enum HTTPFileUploader {
    case data(Data)
    case url(URL)
}

final public class HTTPUploadRequest: HTTPRequest, Builder {
    
    public typealias CompletionHandler = HTTPDataResponseHandler
    public typealias Buildable = HTTPUploadRequest
    
    private var _fileUploader: HTTPFileUploader?
    private var _mutltiPartDataHandler: HTTPMultiPartDataHandler?
    private var _dataCompletionHandler: HTTPDataResponseHandler?
    
    public static func builder() -> HTTPUploadRequest {
        let request = Buildable()
        return request
    }
    
    public func url(_ url: URLRepresentable) -> HTTPUploadRequest {
        self.url = url
        return self
    }
    
    public func urlRequest(_ url: URLRequestRepresentable) -> HTTPUploadRequest {
        self.url = url
        return self
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPUploadRequest {
        self.parameters = parameters
        return self
    }
    
    public func header(_ header: HTTPHeader) -> HTTPUploadRequest {
        self.header = header
        return self
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPUploadRequest {
        self.method = requestMethod
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
        self.progressHandler = progressHandler
        return self
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDataResponseHandler) -> HTTPUploadRequest {
        self._dataCompletionHandler = completionHandler
        return self
    }
    
    public func `catch`(_ errorHandler: @escaping HTTPErrorHandler) -> HTTPUploadRequest {
        self.errorHandler = errorHandler
        return self
    }
    
    
    public func build() -> Buildable {
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
            var urlRequest = URLRequest(url: try url.asURl())
            urlRequest.httpMethod = method.rawValue
            urlRequest.httpBody = try multiPartData?.encode()
            header["Connection"] = "Keep-Alive"
            header["Content-Type"] = "multipart/form-data"
            urlRequest.allHTTPHeaderFields = header
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
