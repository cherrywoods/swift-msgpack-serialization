//
//  StrFormatFamilyMeta.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 29.10.17.
//

import Foundation
import MetaSerialization

/**
 A Meta for storing strings.
 Ensures, that the lengths of the strings do not exceede 2^32-1 characters.
 Only used during encoding.
 */
internal struct MsgpackString: GenericMeta {
    
    typealias SwiftValueType = String
    
    var value: String?
    
    mutating func set(value: Any) throws {
        
        // check, that value is a String
        guard let stringValue = value as? String else {
            
            preconditionFailure("Called set(value:) with invalid type. Expected String")
        }
        
        // check that the string isn't too long
        guard UInt64( stringValue.count ) < UInt64( 1<<32 ) else {
            
            throw MsgpackError.valueExceededSupportedLength
        }
        
        
        self.value = stringValue
    }
    
}
