//
//  MsgpackExtension.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 11.11.17.
//

import Foundation

/**
 Implement this protocol, if you want to use a msgpack extension to encode your certain swift class or struct.
 
 This protocol provides a default implementation for the encode(to: Encoder) and init(from: Decoder) methods of Codable, that creates/gets a MsgpackExtensionValue and encodes/decodes that.
 */
public protocol MsgpackExtension: Codable {
    
    /// a byte value (between 0 and 127 for application specific extensions, between -128 and -1 for predefined types) that specifies the type of the extension
    var extensionTypeCode: Int8 { get }
    
    /**
     Convert this object to a byte array for transmission with msgpack.
     
     Do not build a final msgpack code! Just return your object represented as data. (Do not include any msgpack header or your extension type code, etc.)
     */
    func encodeSelf() throws -> Data
    
    /**
     initalizazion from the given byte array.
     */
    init(from data: Data) throws
    
}

public extension MsgpackExtension {
    
    public init(from decoder: Decoder) throws {
        
        // decode MsgpackExtensionValue
        let extValue = try MsgpackExtensionValue(from: decoder)
        try self.init(from: extValue.data)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        // create MsgpackExtensionValue first
        let extValue = try MsgpackExtensionValue(type: self.extensionTypeCode,
                                                 data: try self.encodeSelf())
        
        // now let that encode itself
        try extValue.encode(to: encoder)
        
    }
    
}
