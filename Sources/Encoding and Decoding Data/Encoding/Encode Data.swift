//
//  Encode Data.swift.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation
import MetaSerialization

internal extension Data {
    
    func encodeToMsgpack() -> Data {
        
        switch self.count {
        case 0..<(1<<8): // 1<<8 is (2^8) (256)
            // bin8
            // self.count is representable within one byte
            return combine(header: MsgpackHeader.bin8.rawValue,
                           length: [ UInt8(self.count) ],
                           furtherData: self )
            
        case 0..<(1<<16): // 1<<16 is (2^16)
            // bin16
            let lengthBytes = breakUpUInt16ToBytes( UInt16(self.count) )
            return combine(header: MsgpackHeader.bin16.rawValue,
                           length: lengthBytes,
                           furtherData: self )
            
        default:
            
            // on 32-bit platforms, Int is just 32 bits large
            // and therfor 1<<32 would not fit in one Int
            // and could trigger a strange runtime error on those platforms
            if let uint32Length = UInt32(exactly: self.count ) {
                
                // bin32
                let lengthBytes = breakUpUInt32ToBytes( uint32Length )
                return combine(header: MsgpackHeader.bin32.rawValue,
                               length: lengthBytes,
                               furtherData: self )
                
            } else {
                // This should never happen (because of MsgpackBinary Meta)
                preconditionFailure("Data exceeded legitimate length and could therfor not be encoded.")
            }
        }
        
    }
    
}

extension Array where Element == UInt8 {
    
    func encodeToMsgpack() -> Data {
        
        return Data(bytes: self).encodeToMsgpack()
        
    }
    
}
