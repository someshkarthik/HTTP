//
//  HTTPDownloadRequest.swift
//  InstaSaver
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

open class HTTPDownloadRequest: HTTPRequest, TaskBuilder {
    
    public typealias CompletionHandler = HTTPDownloadResponseHandler
    public typealias RequestBuilder = HTTPDownloadRequest
    public typealias HTTPDownloadFileDestination = (_ defaultDestinationURl: URL,_ response: HTTPURLResponse?) -> (URL,DestinationFileOptions)

    private var resumableData: Data?
    private var _downloadCompletionHandler: HTTPDownloadResponseHandler?
    private var _fileDestination: HTTPDownloadFileDestination?
    
    public static func builder() -> HTTPDownloadRequest {
        let request = HTTPDownloadRequest()
        return request
    }
    
    public func url(_ url: URLConvertible) -> HTTPDownloadRequest {
        self._url = url
        return self
    }
    
    public func urlRequest(_ url: URLRequestConvertible) -> HTTPDownloadRequest {
        self._url = url
        return self
    }
    
    public func queryParameters(_ parameters: HTTPParameters) -> HTTPDownloadRequest {
        self._parameters = parameters
        return self
    }
    
    public func header(_ header: HTTPHeader) -> HTTPDownloadRequest {
        self._header = header
        return self
    }
    
    public func requestMethod(_ requestMethod: HTTPMethod) -> HTTPDownloadRequest {
        self._method = requestMethod
        return self
    }
    
    public func fileDestination(_ fileDestination: @escaping HTTPDownloadFileDestination) -> HTTPDownloadRequest {
        self._fileDestination = fileDestination
        return self
    }
    
    public func completionHandler(_ completionHandler: @escaping HTTPDownloadResponseHandler) -> HTTPDownloadRequest {
        self._downloadCompletionHandler = completionHandler
        return self
    }
    
    public func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> HTTPDownloadRequest {
        self._progressHandler = progressHandler
        return self
    }
    
    @discardableResult
    public func build() -> RequestBuilder {
        var urlRequest: URLRequest
        if let urlRequestConvertible = _url as? URLRequestConvertible {
            urlRequest = urlRequestConvertible.asURLRequest()
        } else {
            do {
                let url = try _url.asURl()
                urlRequest = URLRequest(url: url)
                urlRequest.timeoutInterval = sessionConfiguration.timeoutIntervalForRequest
                urlRequest.allowsCellularAccess = sessionConfiguration.allowsCellularAccess
                urlRequest.httpMethod = _method?.rawValue
                
                for (key,value) in _header {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            } catch { encodeToErrorResponse(error, from: nil); return self}
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

extension HTTPDownloadRequest: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let finalDestinationURL: URL
        do {
            if let fileDestination = self._fileDestination?(location,downloadTask.response as? HTTPURLResponse) {
                let destinationURL = fileDestination.0
                let fileDestinationOption = fileDestination.1
                
                //remove duplicate files
                if fileDestinationOption.contains(.removeDuplicate), FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                //create intermediate directories if present
                if fileDestinationOption.contains(.createIntermediateDirectories) {
                    let directory = destinationURL.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                }
                finalDestinationURL = destinationURL
            } else {
                var url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                url.appendPathComponent(location.lastPathComponent)
                finalDestinationURL = url
            }
            try FileManager.default.moveItem(at: location, to: finalDestinationURL)
        }catch {
            encodeToErrorResponse(error, from: downloadTask.response); return
        }
        
        
        let result: DownloadResult = .success(finalDestinationURL)
        let httpResponse = DownloadResponse(data: nil, response: downloadTask.response, result: result)
        DispatchQueue.main.async {[weak self] in
            self?._downloadCompletionHandler?(httpResponse)
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        let progress = downloadTask.progress
        progress.completedUnitCount = fileOffset
        progress.totalUnitCount = expectedTotalBytes
        DispatchQueue.main.async { [weak self] in
            self?._progressHandler?(progress)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = downloadTask.progress
        progress.completedUnitCount = totalBytesWritten
        progress.totalUnitCount = totalBytesExpectedToWrite
        
        DispatchQueue.main.async {[weak self] in
            self?._progressHandler?(progress)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            let userInfo = error._userInfo
            self.resumableData = userInfo?[NSURLSessionDownloadTaskResumeData] as? Data
            encodeToErrorResponse(error, from: task.response)
        }
    }
    
    private func encodeToErrorResponse(_ error: Error,from response: URLResponse?) {
        let result: DownloadResult = .failure(error.httpError)
        let httpResponse: DownloadResponse = .init(data: nil, response: response, result: result)
        DispatchQueue.main.async {[weak self] in
            self?._downloadCompletionHandler?(httpResponse)
        }
        
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
