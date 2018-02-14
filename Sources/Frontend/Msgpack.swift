//
//  Msgpack.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

/**
 A value representing encoded msgpack.
 
 Calling init(encoding: ) may throw the following errors:
 - EncodingError
 - MsgpackError
 - MetaEncodingError and StackError from MetaSerialization. One of these errors indicates a bug eigther in this framework, MetaSerialization or the custom encoding code.
 
 Calling decode(type:) may throw the following errors:
 - DecodingError
 - MsgpackError
 - MetaEncodingError and StackError from MetaSerialization. One of these errors indicates a bug eigther in this framework, MetaSerialization or the custom decoding code.
 */
public protocol Msgpack: Representation {  }

// MARK: default implementations

extension Msgpack {
    
    public func provideNewDecoder() throws -> MetaDecoder {
        
        return try MsgpackDecoder(raw: self)
        
    }
    
    public static func provideNewEncoder() -> MetaEncoder {
        
        return MsgpackEncoder()
        
    }
    
}
