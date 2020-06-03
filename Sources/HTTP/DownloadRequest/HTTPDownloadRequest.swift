//
//  HTTPDownloadRequest.swift
//  HTTP
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

final internal class HTTPDownloadRequest: HTTPRequest, Builder {
    private var resumableData: Data?
    
    var downloadCompletionHandler: HTTPDownloadResponseHandler?
    let downloadRequestDelegate: HTTPDownloadRequestDelegate = .init()
    
    public static func builder() -> HTTPDownloadRequest {
        let request = HTTPDownloadRequest()
        return request
    }

    @discardableResult
    public func build() -> HTTPDownloadRequest {
        downloadRequestDelegate.delegate = self
        
        var urlRequest: URLRequest
        if let urlRequestConvertible = url as? URLRequestRepresentable {
            urlRequest = urlRequestConvertible.asURLRequest()
        } else {
            do {
                let _url = try url.asURl()
                urlRequest = URLRequest(url: _url)
            } catch {
                httpDownloadRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError),
                    resumableData: nil
                )
                return self
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        
        if !parameters.isEmpty {
            do { try urlRequest.url?.encode(withParameters: self.parameters) }
            catch {
                httpDownloadRequestDelegate(
                    finishedWithError: .init(data: nil, response: nil, result: error.httpError),
                    resumableData: nil
                )
                return self
            }
        }
        
        for (key,value) in header {
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
        errorHandler?(error)
    }
    
    func httpDownloadRequestDelegate(finishedWithURL url: DownloadResponse) {
        downloadCompletionHandler?(url)
    }
    
    func httpDownloadRequestDelegate(_ progress: Progress) {
        progressHandler?(progress.httpProgress)
    }
}
