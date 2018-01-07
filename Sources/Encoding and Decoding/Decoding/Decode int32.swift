//
//  Decode Int32.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for int32 and uint32 msgpack values

extension RawMsgpack {
    
    func decodeInt32() throws -> Meta {
        
        // make sure, that msgpack has four bytes
        try isValid(self, index: 3)
        
        let uint32 = UInt32(bigEndian: combineUInt32(from: self[0..<4]))
        return IntFormatMeta(value: Int32(bitPattern: uint32))
        
    }
    
    func decodeUInt32() throws -> Meta {
        
        // make sure, that msgpack has four bytes
        try isValid(self, index: 3)
        
        let uint32 = UInt32(bigEndian: combineUInt32(from: self[0..<4]))
        return IntFormatMeta(value: uint32)
        
    }
    
}
