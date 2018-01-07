//
//  RawMsgpack + Decoding.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// this file contains first step decoding code

extension RawMsgpack {
    
    func decode(with options: Configuration) throws -> Meta {
        
        switch header {
            
        // nil
        case .nilHeader:
            return NilMeta.nil
            
        // Bool
        case .trueHeader:
            return SimpleGenericMeta(value: true)
        case .falseHeader:
            return SimpleGenericMeta(value: false)
            
        // Int...
            
        // fixnum
        case .positiveFixnum:
            // since the header is 0, we may just interpret the header byte
            // that also contains the numeric value we are interested in
            // as an Int
            return try decodeInt8()
        case .negativeFixnum:
            // because the header is 111, it is possible
            // to just interpret the whole header byte as
            // a two's complement negative integer
            return try decodeInt8()
            
        // other ints and uints
        case .int8:
            return try decodeInt8()
        case .uint8:
            return try decodeUInt8()
        case .int16:
            return try decodeInt16()
        case .uint16:
            return try decodeUInt16()
        case .int32:
            return try decodeInt32()
        case .uint32:
            return try decodeUInt32()
        case .int64:
            return try decodeInt64()
        case .uint64:
            return try decodeUInt64()
           
        // Float and Double
        case .float32:
            return try decodeFloat32()
        case .float64:
            return try decodeFloat64()
            
        // String
        case .fixstr, .str8, .str16, .str32:
            return try decodeString()
        
        // Data
        case .bin8, .bin16, .bin32:
            return try decodeBinary()
            
        // MsgpackExtension (including timestamp)
        case .fixext1, .fixext2, .fixext4, .fixext8, .fixext16, .ext8, .ext16, .ext32:
            return try decodeExtension(with: options)
        // Array
        case .fixarray, .array16, .array32:
            return try decodeArray(with: options)
        
        // Map
        case .fixmap, .map16, .map32:
            return try decodeMap(with: options)
            
        }
        
    }
    
}
