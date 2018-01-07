//
//  Decode exts.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for fixext1, fixexr2, fixext4, fixext8, fixext16, ext8, ext16 and ext32 msgpack values

extension RawMsgpack {
    
    func decodeExtension(with options: Configuration) throws -> Meta {
        
        guard var data = self.valueData else {
            // asserting that this function was called with a ext header, data may not be nil
            throw MsgpackError.invalidMsgpack
        }
        
        // first byte is the type code
        let type = MsgpackExtensionValue.type(fromTypeCode: data.removeFirst())
        let furtherData = data // first byte is removed before
        
        // if type is -1 (timestamp), decode to Date
        if type == PredefinedExtensionType.timeStamp.rawValue {
            
            return try decodeTimestamp(with: options)
            
        } else {
            
            // otherwise, decode as normal extension
            let extensionValue = try MsgpackExtensionValue(type: type, data: furtherData)
            return SimpleGenericMeta<MsgpackExtensionValue>(value: extensionValue)
            
        }
        
    }
    
}
