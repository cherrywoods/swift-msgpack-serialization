//
//  MsgpackBinaryData.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 31.10.17.
//

import Foundation
import MetaSerialization

/**
 A Meta for storing binary data.
 Makes sure, that the data given to set is shorter that 2^32 bytes.
 Only used during encoding.
 */
internal struct MsgpackBinaryData: GenericMeta {
    
    typealias SwiftValueType = Data
    
    var value: Data?
    
    mutating func set(value: Any) throws {
        
        // check, that value is of type Data
        guard let dataValue = value as? Data else {
            
            preconditionFailure("Called set(value:) with invalid type. Expected Data")
        }
        
        // check that the data isn't too long
        guard UInt64( dataValue.count ) < UInt64( 1<<32 ) else {
            
            throw MsgpackError.valueExceededSupportedLength
        }
        
        self.value = dataValue
        
    }
    
}

/**
 A Meta for storing binary data.
 Makes sure, that the data given to set is shorter that 2^32 bytes.
 Only used during encoding.
 */
internal struct MsgpackBinaryByteArray: GenericMeta {
    
    typealias SwiftValueType = [UInt8]
    
    var value: [UInt8]?
    
    mutating func set(value: Any) throws {
        
        // check, that value is of type [UInt8]
        guard let dataValue = value as? [UInt8] else {
            
            preconditionFailure("Called set(value:) with invalid type. Expected [UInt8]")
        }
        
        // check that the data isn't too long
        guard UInt64( dataValue.count ) < UInt64( 1<<32 ) else {
            
            throw MsgpackError.valueExceededSupportedLength
        }
        
        self.value = dataValue
        
    }
    
}
