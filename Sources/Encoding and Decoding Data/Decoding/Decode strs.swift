//
//  Decode strs.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for fixstr, str8, str16 and str32 msgpack values

extension RawMsgpack {
    
    func decodeString() throws -> Meta {
        
        guard let data = self.valueData else {
            // asserting, that this function was called with a string header, data may not be nil
            throw MsgpackError.invalidMsgpack
        }
        
        guard let string = String.init(data: data, encoding: .utf8) else {
            // provide the raw data if string is invalid
            throw MsgpackError.invalidStringData(rawData: data)
            
        }
        
        return SimpleGenericMeta<String>(value: string)
        
    }
    
}
