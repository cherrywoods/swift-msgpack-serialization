//
//  Decode Int16.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for int16 and uint16 msgpack values

extension RawMsgpack {
    
    func decodeInt16() throws -> Meta {
        
        // make sure, that msgpack has two bytes
        try isValid(self, index: 1)
        
        let uint16 = UInt16(bigEndian: combineUInt16(from: self[0..<2]))
        return IntFormatMeta(value: Int16(bitPattern: uint16))
        
    }
    
    func decodeUInt16() throws -> Meta {
        
        // make sure, that msgpack has two bytes
        try isValid(self, index: 1)
        
        let uint16 = UInt16(bigEndian: combineUInt16(from: self[0..<2]))
        return IntFormatMeta(value: uint16)
        
    }
    
}
