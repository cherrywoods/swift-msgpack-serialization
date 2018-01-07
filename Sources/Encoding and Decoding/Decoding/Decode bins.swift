//
//  Decode bins.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for bin8, bin16 and bin32 msgpack values

extension RawMsgpack {
    
    func decodeBinary() throws -> Meta {
        
        guard let data = self.valueData else {
            // asserting that this function was called with a bin header, data may not be nil
            throw MsgpackError.invalidMsgpack
        }
        
        return SimpleGenericMeta<Data>(value: data)
        
    }
    
}
