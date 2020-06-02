//
//  TaskBuilder.swift
//  
//
//  Created by somesh-8758 on 25/05/20.
//

import Foundation

internal protocol TaskBuilder: Builder {
    associatedtype ResponseType
    typealias CompletionHandler = (ResponseType)->Void
    
    func url(_ url: URLRepresentable) -> Buildable
    func urlRequest(_ url: URLRequestRepresentable) -> Buildable
    func header(_ header: HTTPHeader) -> Buildable
    func requestMethod(_ requestMethod: HTTPMethod) -> Buildable
    func queryParameters(_ parameters: HTTPParameters) -> Buildable
    func sessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Buildable
    func progressHandler(_ progressHandler: @escaping HTTPProgressHandler) -> Buildable
    func completionHandler(_ completionHandler: @escaping CompletionHandler) -> Buildable
    func `catch`(_ errorHandler: @escaping HTTPErrorHandler) -> Buildable
}
