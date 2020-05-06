//
//  HTTPResponseSerializer.swift
//  InstaSaver
//
//  Created by somesh-8758 on 21/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public protocol Serializer {
    associatedtype SerializedObject
    func serializedObject(_ response: DataResponse) -> HTTPResponse<SerializedObject,HTTPError>
}

private extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension Data: Serializer {
    public func serializedObject(_ response: DataResponse) -> DataResponse {
        return DataResponse(data: response.data, response: response.urlResponse, result: .failure(HTTPError.dataParsingError()))
    }
    
    public typealias SerializedObject = Data
}

extension String: Serializer {
    public typealias SerializedObject = String

    public func serializedObject(_ response: DataResponse) -> StringResponse {
        return response.stringSerialiser()
    }
}

internal extension HTTPResponse where Success == Data,Failure == HTTPError {
    
    func stringSerialiser() -> StringResponse {
        let newResult: StringResult
        switch result {
        case let .failure(error):
            newResult = .failure(error)
        case .success:
            if let value = value?.toString() {
                newResult = .success(value)
            } else {
                newResult = .failure(HTTPError.dataParsingError())
            }
        }
        let response: StringResponse = .init(data: self.data, response: self.urlResponse, result: newResult)
        return response
    }
    
    func jsonSerialiser() -> JSONResponse {
        let newResult: JSONResult
        if let data = value {
            do {
                if let serialiser = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSON {
                    newResult = .success(serialiser)
                } else {
                    newResult = .failure(HTTPError.dataParsingError())
                }
            } catch {
                newResult = .failure(HTTPError(error: error))
            }
        } else {
            newResult = .failure(HTTPError.dataParsingError())
        }
        let response: JSONResponse = .init(data: self.data, response: self.urlResponse, result: newResult)
        return response
    }
    
}
