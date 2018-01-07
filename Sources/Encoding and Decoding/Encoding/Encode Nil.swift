//
//  Encode Nil.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

extension NilMeta {
    
    func encodeToMsgpack() -> Data {
        
        // nil is just the nil header
        return Data(bytes: [MsgpackHeader.nilHeader.rawValue])
        
    }
    
}
