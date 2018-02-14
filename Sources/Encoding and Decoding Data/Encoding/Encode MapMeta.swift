//
//  Encode MapMeta.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 03.12.17.
//

import Foundation
import MetaSerialization

internal extension MapMeta {
    
    func encodeToMsgpack(with options: Configuration) throws -> Data {
        
        let map = self.map
        
        // recursively encode all key-value-pairs
        var encodedElements: Data = Data()
        for (keyMeta, valueMeta) in map {
            // first add the encoded key and then the encoded value to data
            encodedElements.append( try encodeToData(with: options, meta: keyMeta) )
            encodedElements.append( try encodeToData(with: options, meta: valueMeta) )
        }
        
        let elements = map.count
        switch elements {
        case 0..<(1<<4): // 1<<4 is (2^4) (16)
            // fixmap
            let header = MsgpackHeader.fixmap
                .merge(additionalInformation: UInt8(elements))!
            
            return combine(header: header,
                           length: [],
                           furtherData: encodedElements)
            
        case 0..<(1<<16): // 1<<16 is (2^16)
            // map 16
            let lengthBytes = breakUpUInt16ToBytes( UInt16(elements) )
            return combine(header: MsgpackHeader.map16.rawValue,
                           length: lengthBytes,
                           furtherData: encodedElements)
            
        default:
            
            // on 32-bit platforms, Int is just 32 bits large
            // and therfor 1<<32 would not fit in one Int
            // and could trigger a strange runtime error on those platforms
            if let uint32Length = UInt32(exactly: elements) {
                
                //map 32
                let lengthBytes = breakUpUInt32ToBytes( uint32Length )
                return combine(header: MsgpackHeader.map32.rawValue,
                               length: lengthBytes,
                               furtherData: encodedElements)
                
            } else {
                // Map contained more than 2^32-1 values
                throw MsgpackError.valueExceededSupportedLength
            }
        }
        
    }
    
}
