//
//  MultiPartData.swift
//  HTTP
//
//  Created by somesh-8758 on 22/03/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

struct Boundary {
    
    struct `Type`: OptionSet {
        typealias RawValue = Int
        let rawValue: RawValue
        static let initial = Type(rawValue: 1<<0 )
        static let middle = Type(rawValue: 1<<1 )
        static let final = Type(rawValue: 1<<2 )
        static let none = Type(rawValue: 1<<3)
        static let all: Type = [.initial,.middle,.final]
        
        var hasInitial: Bool {
            return self.contains(.initial)
        }
        
        var hasMiddle: Bool {
            return self.contains(.middle)
        }
        
        var hasFinal: Bool {
            return self.contains(.final)
        }
    }
    
    static var generateRandomBoundary: String {
        return String(format: "HTTPUploadRequest.BoundaryData.%08x%08x", arc4random(), arc4random())
    }
    
    static func boundaryData(for type: Type, boundary: String) -> Data{
        switch type {
        case .initial:
            return "--\(boundary)\r\n".data
        case .middle:
            return "\r\n--\(boundary)\r\n".data
        case .final:
            return "\r\n--\(boundary)--\r\n".data
        default:
            fatalError("unsupported type")
        }
    }
}

final public class BodyPart {
    let contentHeader: HTTPHeader
    let inputBufferStream: InputStream
    let contentLength: UInt64
    var type: Boundary.`Type` = .none
    
    init(headers: HTTPHeader, inputBufferStream: InputStream, contentLength: UInt64) {
        self.contentHeader = headers
        self.inputBufferStream = inputBufferStream
        self.contentLength = contentLength
    }
}

public struct MultiPartData {
    public private(set) var boundary: String
    public private(set) var bodyParts: [BodyPart] = []
    public private(set) var bufferSize: Int = 1024
    
    var totalContenLength: UInt64 {
        bodyParts.reduce(0){ return $0 + $1.contentLength }
    }
    
    var contentType: String {
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    
    init() {
        boundary = "Boundary-\(Boundary.generateRandomBoundary)"
    }
    
    public mutating func append(fieldName: String, fileData: Data) {
        let contentHeader = createHeader(fieldName: fieldName)
        let buffer = InputStream(data: fileData)
        let contentLength = fileData.count
        appendToBodyPart(buffer: buffer, header: contentHeader, contentLength: UInt64(contentLength))
    }
    
    public mutating func append(fieldName: String, mimeType: String, fileData: Data) {
        let contentHeader = createHeader(fieldName: fieldName, mimeType: mimeType)
        let buffer = InputStream(data: fileData)
        let contentLength = fileData.count
        appendToBodyPart(buffer: buffer, header: contentHeader, contentLength: UInt64(contentLength))
    }
    
    public mutating func append(fieldName: String, fileName: String, mimeType: String, fileData: Data) {
        let contentHeader = createHeader(fieldName: fieldName, fileName: fileName, mimeType: mimeType)
        let buffer = InputStream(data: fileData)
        let contentLength = fileData.count
        appendToBodyPart(buffer: buffer, header: contentHeader, contentLength: UInt64(contentLength))
    }
    
    private func createHeader(fieldName: String, fileName: String? = nil, mimeType: String? = nil) -> HTTPHeader{
        var contentDisposition = "form-data; name=\"\(fieldName)\""
        if let fileName = fileName {
            contentDisposition += "; filename=\"\(fileName)\""
        }
        var header = ["Content-Disposition:" : contentDisposition]
        if let mimeType = mimeType {
            header["Content-Type:"] = mimeType
        }
        return header
    }
    
    private mutating func appendToBodyPart(buffer: InputStream,header: HTTPHeader,contentLength: UInt64) {
        let bodyPart = BodyPart(headers: header, inputBufferStream: buffer, contentLength: contentLength)
        bodyParts.append(bodyPart)
    }
    
    mutating public func encode() throws -> Data {
        var encodedData = Data()
        if let first = bodyParts.first {
            first.type.insert(.initial)
            bodyParts[0] = first
        }
        
        if let last = bodyParts.last {
            last.type.insert(.final)
            bodyParts[0] = last
        }
        
        for bodyPart in bodyParts {
            try encodedData.append(encode(bodyPart))
        }
        
        return encodedData
    }
    
    private func encode(_ bodyPath: BodyPart) throws -> Data {
        var newData = Data()
        
        let initialData = bodyPath.type.hasInitial ? initialBoundaryData() : middleBoundaryData()
        newData.append(initialData)
        
        let contentHeaderData = encodeContentHeader(bodyPath.contentHeader)
        newData.append(contentHeaderData)
        
        let inputBufferStreamData = try encodeInputBufferStream(bodyPath.inputBufferStream)
        newData.append(inputBufferStreamData)
        
        if bodyPath.type.hasFinal {
            newData.append(finalBoundaryData())
        }
        
        return newData
    }
    
    private func encodeInputBufferStream(_ inputBufferStream: InputStream) throws -> Data {
        inputBufferStream.open()
        
        var newData = Data()
        
        while inputBufferStream.hasBytesAvailable {
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            let buffersRead = inputBufferStream.read(&buffer, maxLength: bufferSize)
            
            if let error = inputBufferStream.streamError {
                throw HTTPError(error: error)
            }
            
            if buffersRead > 0 {
                newData.append(buffer, count: buffersRead)
            } else {
                break
            }
        }
        
        inputBufferStream.close()
        return newData
    }
    
    private func encodeContentHeader(_ header: HTTPHeader) -> Data {
        var contentHeader: String = ""
        for (key, value) in header {
            contentHeader += "\(key) \(value)\r\n"
        }
        contentHeader += "\r\n"
        return contentHeader.data
    }
    
    private func mimeType(for pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }
    
    private func initialBoundaryData() -> Data {
        return Boundary.boundaryData(for: .initial, boundary: boundary)
    }
    
    private func middleBoundaryData() -> Data {
        return Boundary.boundaryData(for: .middle, boundary: boundary)
    }
    
    private func finalBoundaryData() -> Data {
        return Boundary.boundaryData(for: .final, boundary: boundary)
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: true)
        self.append(data!)
    }
}

extension String {
    var data: Data {
        return data(using: .utf8, allowLossyConversion: true)!
    }
}
