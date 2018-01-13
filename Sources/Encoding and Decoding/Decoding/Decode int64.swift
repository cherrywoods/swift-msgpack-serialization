//
//  Decode int64.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for int64 and uint64 msgpack values

extension RawMsgpack {
    
    func decodeInt64() throws -> Meta {
        
        // make sure, that self has eigth bytes
        try isValid(self, index: 7)
        
        let uint64 = UInt64(combineUInt64(from: self[0..<8]))
        return IntFormatMeta(value: Int64(bitPattern: uint64))
        
    }
    
    func decodeUInt64() throws -> Meta {
        
        // make sure, that self has eigth bytes
        try isValid(self, index: 7)
        
        // note that combineUInt32 interprets data as big endian integer
        let uint64 = UInt64(combineUInt64(from: self[0..<8]))
        return IntFormatMeta(value: uint64)
        
    }
    
}
