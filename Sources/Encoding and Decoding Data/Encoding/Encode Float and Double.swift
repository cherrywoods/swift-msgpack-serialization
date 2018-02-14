//
//  Encode Float and Double.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation
import MetaSerialization

internal extension Float {
    
    func encodeToMsgpack() -> Data {
        
        // float 32
        // do not change the byte order of the bit pattern!
        let ieee754SinglePrecision = self.bitPattern
        
        let bytes = breakUpUInt32ToBytes(ieee754SinglePrecision)
        return combine(header: MsgpackHeader.float32.rawValue,
                       bytes: bytes)
        
    }
    
}

internal extension Double {
    
    func encodeToMsgpack() -> Data {
        
        /*
         Always use the smallest representation for a value
         */
        
        /*
         check first whether value is a Float, if so, cast it,
         if not, it needs to be a Double,
         because other floating point types are not supported and in this case,
         check whether it can be represented as Float
         */
        if let floatValue = Float(exactly: self) {
            
            // encode as Float
            return floatValue.encodeToMsgpack()
            
        } else {
            
            // float 64
            let ieee754DoublePrecision = self.bitPattern
            let bytes = breakUpUInt64ToBytes(ieee754DoublePrecision)
            return combine(header: MsgpackHeader.float64.rawValue,
                           bytes: bytes)
            
        }
        
    }
    
}
