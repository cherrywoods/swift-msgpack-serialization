//
//  Decode int8.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for int8 and uint8 msgpack values

extension RawMsgpack {
    
    func decodeInt8() throws -> Meta {
        
        // make sure, that msgpack has a byte
        try isValid(self, index: 0)
        
        let uint8 = self[0]
        return IntFormatMeta(value: Int8(bitPattern: uint8))
        
    }
    
    func decodeUInt8() throws -> Meta {
        
        // make sure, that msgpack has a byte
        try isValid(self, index: 0)
        
        return IntFormatMeta(value: self[0])
        
    }
    
}
