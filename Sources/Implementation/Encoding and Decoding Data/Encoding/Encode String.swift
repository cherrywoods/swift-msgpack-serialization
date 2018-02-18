//
//  Encode String.swift.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 20.11.17.
//

import Foundation
import MetaSerialization

internal extension String {
    
    func encodeToMsgpack(with optionSet: Configuration) throws -> Data {
        
        // msgpack specification sets utf8 as string encoding
        guard let primaryData = self.data(using: .utf8, allowLossyConversion: optionSet.allowLoosyStringConversion) else {
            // this will ony happen, if the encodingOption specifies that no loosy conversion is allowed
            throw MsgpackError.stringCouldNotBeRepresentedUsingUTF8(string: self)
        }
        
        switch primaryData.count {
            
        case 0..<31:
            // fixstr
            let header = MsgpackHeader.fixstr.merge(additionalInformation: UInt8(primaryData.count))
            return combine(header: header!,
                           furtherData: primaryData)
            
        case 0..<(1<<8): // 1<<8 is (2^8) (256)
            // str8
            return combine(header: MsgpackHeader.str8.rawValue,
                           length: [ UInt8( primaryData.count ) ],
                           furtherData: primaryData)
            
        case 0..<(1<<16): // 1<<16 is (2^16)
            // str16
            let lengthBytes = breakUpUInt16ToBytes( UInt16( primaryData.count ) )
            return combine(header: MsgpackHeader.str16.rawValue,
                           length: lengthBytes,
                           furtherData: primaryData)
            
        default:
            
            // on 32-bit platforms, Int is just 32 bits large
            // and therfor 1<<32 would not fit in one Int
            // and could trigger a strange runtime error on those platforms
            
            if let uint32Length = UInt32(exactly: primaryData.count ) {
                
                // bin32
                let lengthBytes = breakUpUInt32ToBytes( uint32Length )
                return combine(header: MsgpackHeader.bin32.rawValue,
                               length: lengthBytes,
                               furtherData: Data( primaryData ) )
                
            } else {
                // This should never happen because it is ensured by MsgpackString
                preconditionFailure("Data exceeded legitimate length and could therfor not be encoded.")
            }
            
        }
        
    }
    
}
