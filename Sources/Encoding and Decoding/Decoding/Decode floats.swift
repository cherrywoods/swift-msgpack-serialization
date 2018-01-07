//
//  Decode float32.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for float32 and float64 msgpack values

extension RawMsgpack {
    
    func decodeFloat32() throws -> Meta {
        
        // make sure, that this msgpack has four bytes
        try isValid(self, index: 3)
        
        // read bitPattern from the four value bytes
        // the bitPatterns need to stay in the order it is,
        // do not apply bigEndian or littleEndian
        let bitPattern = combineUInt32(from: self[0..<4])
        
        // FloatFormatMeta handles the conversion to the desired BinaryFloatingPoint type from the user
        return FloatFormatMeta(value: Float(bitPattern: bitPattern))
        
    }
    
    func decodeFloat64() throws -> Meta {
        
        // make sure, that this msgpack has eight bytes
        try isValid(self, index: 7)
        
        // read bitPattern from the eigth value bytes
        let bitPattern = combineUInt64(from: self[0..<8])
        
        // FloatFormatMeta handles the conversion to the desired BinaryFloatingPoint type from the user
        return FloatFormatMeta(value: Double(bitPattern: bitPattern))
        
    }
    
}
