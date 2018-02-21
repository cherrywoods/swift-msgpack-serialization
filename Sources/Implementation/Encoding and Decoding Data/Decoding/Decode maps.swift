//
//  Decode maps.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for fixmap, map16 and map32 msgpack values

extension RawMsgpack {
    
    func decodeMap(with options: Configuration) throws -> Meta {
        
        let mapMeta = MapMeta()
        
        // the remaining msgpack with the next element of the array it the beginning
        var subMsgpack: RawMsgpack = self
        
        for _ in 0..<self.valueDataLength! {
            
            // a map value should have two msgpack values for each i
            let key = try RawMsgpack.trimAndDecode(subMsgpack: &subMsgpack, with: options)
            let value = try RawMsgpack.trimAndDecode(subMsgpack: &subMsgpack, with: options)
            
            // insert this key-value pair into mapMeta
            mapMeta.add(key: key, value: value)
            
        }
        
        // because .remainingData of a map only removes the header and length
        // it is necessary to set remainingData at the end of this method
        // to the remainingData of the last decoded value
        self.remainingData = subMsgpack.remainingData
        
        return mapMeta
        
    }
    
}
