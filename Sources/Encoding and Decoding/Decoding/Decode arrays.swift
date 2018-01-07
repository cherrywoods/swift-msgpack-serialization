//
//  Decode arrays.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for fixarray, array16 and array32 msgpack values

extension RawMsgpack {
    
    func decodeArray(with options: Configuration) throws -> Meta {
        
        let unkeyedMeta = ArrayUnkeyedContainerMeta()
        
        // the remaining msgpack with the next element of the array it the beginning
        var subMsgpack: RawMsgpack = self
        
        for _ in 0..<self.valueDataLength! {
            
            // decode the next element (at the beginning of subMsgpack)
            unkeyedMeta.append(element: try trimAndDecode(subMsgpack: &subMsgpack, with: options))
            
        }
        
        // because .remainingData of an array only removes the header and length
        // it is necessary to set remainingData at the end of this method
        // to the remainingData of the last decoded element
        self.remainingData = subMsgpack.remainingData
        
        return unkeyedMeta
        
    }
    
    // used by array and by map:
    
    /// trims the last msgpack value of subMsgpack and then decodes the next element. subMsgpack will be trimmed of the old last msgpack value.
    internal func trimAndDecode(subMsgpack: inout RawMsgpack, with options: Configuration) throws -> Meta {
        
        guard subMsgpack.remainingData != nil else {
            throw MsgpackError.invalidMsgpack
        }
        
        // trim of the last decoded element (or the array or map header)
        // we assert here that subMsgpack has remainingData
        subMsgpack = try RawMsgpack(from: subMsgpack.remainingData!)
        
        // decode the next value (at the beginning of subMsgpack)
        return try subMsgpack.decode(with: options)
        
    }
    
}
