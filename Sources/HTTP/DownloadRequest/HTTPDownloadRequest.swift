//
//  HTTPDownloadRequest.swift
//  HTTP
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

final public class HTTPDownloadRequest: HTTPRequest, Builder {
    public typealias HTTPDownloadFileDestination = (_ defaultDestinationURL: URL,_ response: HTTPURLResponse?) -> (targetURL: URL,options: DestinationFileOptions)
    
    private var resumableData: Data?
    
    var _downloadCompletionHandler: HTTPDownloadResponseHandler?
    let downloadRequestDelegate: HTTPDownloadRequestDelegate = .init()
    
    public static func builder() -> HTTPDownloadRequest {
        let request = HTTPDownloadRequest()
        return request
    }

    @discardableResult
    public func build() -> HTTPDownloadRequest {
        downloadRequestDelegate.delegate = self
        
        var urlRequest: URLRequest
        if let urlRequestConvertible = _url as? URLRequestRepresentable {
            urlRequest = urlRequestConvertible.asURLRequest()
        } else {
            do {
                let url = try _url.asURl()
                urlRequest = URLRequest(url: url)
            } catch {
                httpDownloadRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError),
                    resumableData: nil
                )
                return self
            }
        }
        
        urlRequest.httpMethod = _method.rawValue
        
        if !_parameters.isEmpty {
            do { try urlRequest.url?.encode(withParameters: self._parameters) }
            catch {
                httpDownloadRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError),
                    resumableData: nil
                )
                return self}
        }
        
        for (key,value) in _header {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        task = session?.downloadTask(with: urlRequest)
        task?.resume()
        return self
    }
    
    public override func resume() {
        guard task?.state != .running else {return}
        guard task?.state != .suspended else {task?.resume(); return}
        guard (task?.state == .completed && task?.error != nil) ||
            task?.state == .canceling
            else {return}
        guard let data = resumableData else { return }
        
        //should only proceed to resume from prevoius Data if the task is cancelled or failed with error
        task = session?.downloadTask(withResumeData: data)
        task?.resume()
    }
    
    public override func cancel() {
        (task as! URLSessionDownloadTask).cancel {[weak self] (resumableData) in
            self?.resumableData = resumableData
        }
    }
    
}

extension HTTPDownloadRequest: DownloadRequestDelegate {
    func httpDownloadRequestDelegate(finishedWithError error: ErrorResponse, resumableData: Data?) {
        self.resumableData = resumableData
        _errorHandler?(error)
    }
    
    func httpDownloadRequestDelegate(finishedWithURL url: DownloadResponse) {
        _downloadCompletionHandler?(url)
    }
    
    func httpDownloadRequestDelegate(_ progress: Progress) {
        _progressHandler?(progress)
    }
}

public extension HTTPDownloadRequest {
    struct DestinationFileOptions: OptionSet {
        public typealias RawValue = Int
        public var rawValue: HTTPDownloadRequest.DestinationFileOptions.RawValue
        
        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
        
        public static var removeDuplicate = DestinationFileOptions(rawValue: 1<<0)
        public static var createIntermediateDirectories = DestinationFileOptions(rawValue: 1<<1)
    }
}
