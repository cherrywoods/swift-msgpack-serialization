//
//  MsgpackExtensionValue.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 11.11.17.
//

import Foundation

/**
 A container for msgpack extension data used to encode to msgpack using enxtensions.
 
 If you use an extension for your swift type, you need create a MsgpackExtensionValue and encode that. Otherwise swift-msgpack-serialization will not be able to detect your extension
 */
public struct MsgpackExtensionValue: Codable {
    
    public let type: Int8
    public let data: Data
    
    public init(type: Int8, data: Data) throws {
        
        guard UInt64(data.count) < UInt64(1<<32) else {
            throw MsgpackError.valueExceededSupportedLength
        }
        
        self.type = type
        self.data = data
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try decoder.singleValueContainer().decode(MsgpackExtensionValue.self)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var sVC = encoder.singleValueContainer()
        try sVC.encode(self)
        
    }
    
}
