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
 
 Calling encode(_) may throw the following errors:
 - EncodingError
 - MsgpackError
 - MetaEncodingError and StackError from MetaSerialization. One of these errors indicates a bug eigther in this framework, MetaSerialization or the custom encoding code.
 
 Calling decode(toType:, from:) may throw the following errors:
 - DecodingError
 - MsgpackError
 - MetaEncodingError and StackError from MetaSerialization. One of these errors indicates a bug eigther in this framework, MetaSerialization or the custom decoding code.
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
