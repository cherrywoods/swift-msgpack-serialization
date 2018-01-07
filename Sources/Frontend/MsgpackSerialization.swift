//
//  MsgpackSerialization.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 17.12.17.
//

import Foundation
import MetaSerialization

/**
 This class serializes to msgpack over `encode(_)` and deserializes from msgpack over `decode(toType:, from:)`.
 */
public class MsgPacker: Serialization {
    
    // MARK: - serialization
    
    public typealias Raw = Data
    
    public func provideNewEncoder() -> MetaEncoder {
        
        return MsgpackEncoder(with: configuration)
        
    }
    
    public func provideNewDecoder(raw: Data) throws -> MetaDecoder {
        
        return try MsgpackDecoder(with: configuration, raw: raw)
        
    }
    
    // MARK: - configuration
    
    public var configuration: Configuration
    
    public init(with configuration: Configuration = Configuration()) {
        
        self.configuration = configuration
        
    }
    
}
