//
//  Encode Bool.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

internal extension Bool {
    
    func encodeToMsgpack() -> Data {
        
        switch self {
        case true:
            return Data(bytes: [MsgpackHeader.trueHeader.rawValue])
        case false:
            return Data(bytes: [MsgpackHeader.falseHeader.rawValue])
        }
        
    }
    
}
