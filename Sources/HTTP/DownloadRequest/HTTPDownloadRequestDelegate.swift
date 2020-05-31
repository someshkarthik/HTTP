//
//  File.swift
//  
//
//  Created by somesh-8758 on 24/05/20.
//

import Foundation

protocol DownloadRequestDelegate: class {
    func httpDownloadRequestDelegate(finishedWithError error: ErrorResponse, resumableData: Data?)
    func httpDownloadRequestDelegate(finishedWithURL url: DownloadResponse)
    func httpDownloadRequestDelegate(_ progress: Progress)
}

final class HTTPDownloadRequestDelegate: NSObject, URLSessionDownloadDelegate {
    
    var fileDestination: HTTPDownloadRequest.HTTPDownloadFileDestination?
    var delegate: DownloadRequestDelegate?
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let finalDestinationURL: URL
        
        do {
            if let fileDestination = self.fileDestination?(location,downloadTask.response as? HTTPURLResponse) {
                let destinationURL = fileDestination.targetURL
                let fileDestinationOption = fileDestination.options
                
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
        
        delegate?.httpDownloadRequestDelegate(
            finishedWithURL: .init(data: nil, response: downloadTask.response, result: finalDestinationURL)
        )
        delegate = nil
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        progress(downloadTask.progress, from: fileOffset, totalOffset: expectedTotalBytes)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progress(downloadTask.progress, from: totalBytesWritten, totalOffset: totalBytesExpectedToWrite)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            let userInfo = error._userInfo
            encodeToErrorResponse(error, from: task.response,resumableData: userInfo?[NSURLSessionDownloadTaskResumeData] as? Data)
        }
    }
    
    func progress(_ progress: Progress, from completedOffset: Int64,totalOffset: Int64) {
        progress.completedUnitCount = completedOffset
        progress.totalUnitCount = totalOffset
        delegate?.httpDownloadRequestDelegate(progress)
    }
    
    func encodeToErrorResponse(_ error: Error,from response: URLResponse?,resumableData: Data? = nil) {
        delegate?.httpDownloadRequestDelegate(
            finishedWithError: .init(data: nil, response: response, result: error.httpError),
            resumableData: resumableData
        )
        delegate = nil
    }
    
}
