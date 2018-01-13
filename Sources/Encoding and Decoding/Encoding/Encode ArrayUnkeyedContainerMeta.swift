//
//  Encode ArrayUnkeyedContainerMeta.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 20.11.17.
//

import Foundation
import MetaSerialization

extension ArrayUnkeyedContainerMeta {
    
    func encodeToMsgpack(with options: Configuration) throws -> Data {
        
        let array = self.value!
        
        // recursively encode all elements
        var encodedElements: Data = Data()
        for meta in array {
            // encode element and simply append to data
            encodedElements.append( try encode(with: options, meta: meta) )
        }
        
        switch self.count {
        case 0..<(1<<4): // 1<<4 is (2^4) (16)
            // fixarray
            let header = MsgpackHeader.fixarray
                .merge(additionalInformation: UInt8(self.count))!
            
            return combine(header: header,
                           length: [],
                           furtherData: encodedElements)
            
        case 0..<(1<<16): // 1<<16 is (2^16)
            // array 16
            let lengthBytes = breakUpUInt16ToBytes( UInt16(self.count) )
            return combine(header: MsgpackHeader.array16.rawValue,
                           length: lengthBytes,
                           furtherData: encodedElements)
            
        default:
            
            // on 32-bit platforms, Int is just 32 bits large
            // and therfor 1<<32 would not fit in one Int
            // and could trigger a strange runtime error on those platforms
            if let uint32Length = UInt32(exactly: self.count ) {
                
                //array 32
                let lengthBytes = breakUpUInt32ToBytes( uint32Length )
                return combine(header: MsgpackHeader.array32.rawValue,
                               length: lengthBytes,
                               furtherData: encodedElements)
                
            } else {
                // Array contained more than 2^32-1 values
                throw MsgpackError.valueExceededSupportedLength
            }
        }
        
    }
    
}
