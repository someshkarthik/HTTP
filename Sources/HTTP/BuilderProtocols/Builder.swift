//
//  Builder.swift
//  HTTP
//
//  Created by somesh-8758 on 25/05/20.
//

import Foundation

public protocol Builder {
    associatedtype Buildable
    associatedtype Request
    static func builder() -> Buildable
    func build() -> Request
}
