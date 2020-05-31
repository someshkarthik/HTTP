//
//  HTTP.swift
//  HTTP
//
//  Created by somesh-8758 on 24/05/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public struct HTTP {
    public static let shared: HTTP = .init()
    private init() {}
    
    //MARK: NON-CHAINABLE METHODS
    public func dataRequestBuilder() -> HTTPDataRequestBuilder{
        return HTTPDataRequestBuilder.builder()
    }
    
    public func downloadRequestBuilder() -> HTTPDownloadRequestBuilder{
        return HTTPDownloadRequestBuilder.builder()
    }
    
    public func uploadRequestBuilder() {
        //TODO: should implement
    }
    
    //MARK: MULTI-API CHAINABLE METHODS
    @discardableResult
    public func dataRequestBuilder(_ buildableBlock: (HTTPDataRequestBuilder)->Void) -> HTTP {
        buildableBlock(.builder())
        return self
    }
    
    @discardableResult
    public func downloadRequestBuilder(_ buildableBlock: (HTTPDownloadRequestBuilder)->Void) -> HTTP{
        buildableBlock(.builder())
        return self
    }
}
