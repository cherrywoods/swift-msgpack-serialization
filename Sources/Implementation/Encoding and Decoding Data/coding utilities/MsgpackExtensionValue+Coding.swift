//
//  MsgpackExtensionValue+Coding.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 19.11.17.
//

import Foundation

internal extension MsgpackExtensionValue {
    
    // MARK: type code
    
    internal var typeCode: UInt8 {
        return UInt8(bitPattern: type)
    }
    
    internal static func type(fromTypeCode typeCode: UInt8) -> Int8 {
        
        return Int8(bitPattern: typeCode)
        
    }
    
}
