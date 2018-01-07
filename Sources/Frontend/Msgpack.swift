//
//  Msgpack.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

public protocol Msgpack: Representation {  }

extension Data: Msgpack {
    
    public static func provideNewEncoder() -> MetaEncoder {
        
        return MsgpackEncoder()
        
    }
    
    public func provideNewDecoder() throws -> MetaDecoder {
        
        return try MsgpackDecoder(raw: self)
        
    }
    
}
