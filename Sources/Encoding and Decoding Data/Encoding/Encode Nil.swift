//
//  Encode Nil.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

internal extension NilMeta {
    
    func encodeToMsgpack() -> Data {
        
        // nil is just the nil header
        return Data(bytes: [MsgpackHeader.nilHeader.rawValue])
        
    }
    
}
