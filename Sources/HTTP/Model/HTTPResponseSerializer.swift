//
//  HTTPResponseSerializer.swift
//  HTTP
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

private extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

internal extension HTTPResponse where Result == Data {
    
    func stringSerialiser() throws -> StringResponse {
        
        switch value.toString() {
        case .some(let result):
            let response: StringResponse = .init(data: self.data, response: self.urlResponse, result: result)
            return response
        case .none:
            throw HTTPError.dataParsingError()
        }
        
    }
    
    func jsonSerialiser() throws -> JSONResponse {
        
        switch try JSONSerialization.jsonObject(with: value, options: .mutableContainers) as? JSON {
        case .some(let result):
            let response: JSONResponse = .init(data: self.data, response: self.urlResponse, result: result)
            return response
        case .none:
            throw HTTPError.dataParsingError()
        }
        
    }
    
    func decode<T: Decodable>(to decodableType: T.Type) throws -> HTTPResponse<T>{
        let result = try JSONDecoder().decode(decodableType, from: self.value)
        return .init(data: self.data, response: urlResponse, result: result)
    }
    
}
