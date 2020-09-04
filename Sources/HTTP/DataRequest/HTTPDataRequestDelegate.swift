//
//  HTTPDataRequestDelegate.swift
//  HTTP
//
//  Created by somesh-8758 on 24/05/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

protocol DataRequestDelegate: class {
    func httpDataRequestDelegate(_ progress: Progress)
    func httpDataRequestDelegate(finishedWithError error: ErrorResponse)
    func httpDataRequestDelegate(finishedWithData data: DataResponse)
}

final class HTTPDataRequestDelegate: NSObject, URLSessionDataDelegate {
    private var contentLength: Int64 = 0
    private var buffer: Data = .init()
    var delegate: DataRequestDelegate?
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        contentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        let progress = dataTask.progress
        progress.completedUnitCount = Int64(buffer.count)
        progress.totalUnitCount = contentLength
        delegate?.httpDataRequestDelegate(progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        encodeResponse(for: error, response: task.response)
    }
    
    private func encodeResponse(for error: Error?, response: URLResponse?) {
        
        if let error = error {
            delegate?.httpDataRequestDelegate(
                finishedWithError: .init(data: nil, response: response, result: error.httpError)
            )
        } else {
            delegate?.httpDataRequestDelegate(
                finishedWithData: .init(data: buffer, response: response, result: buffer)
            )
            buffer.removeAll()
        }
    }
}
