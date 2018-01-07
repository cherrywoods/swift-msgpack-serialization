//
//  Encode BinaryInteger.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation
import MetaSerialization

/*
 This extensions adds a generic encoding method,
 that finds the smallest possible representation
 in msgpack.
 */
extension BinaryInteger {
    
    /**
     Encodes self.
     */
    func encodeToMsgpack() -> Data {
        
        /**
         Always use the smallest representation for a value
         
         Positive values will be encoded as uints
         only negative as signed representations
         0 will be encoded as positive fixnum
         */
        
        // here, we do not use a simple switch structure, because init(clampling: )
        // would not always result in the smallest possible representation.
        // this cascade of if statements should instead make sure,
        // that every value is representated in as less bits as possible (and supported)
        
        
        // any Integer type supports values inbetween -16 and 127
        
        // positive fixnum
        if (Self.init(0) ... Self.init(127)).contains(self) { // seven bits containing a positive value
            
            // positive fixnum
            let byte = MsgpackHeader.positiveFixnum
                .merge(additionalInformation: UInt8(self).bigEndian)!
            
            return Data([byte])
            
        }
        
        // negative fixnum
        // if Self can not store negative values, Self.int(-16) would fail
        if Self.isSigned {
            
            if (Self.init(-16) ... Self.init(-1)).contains(self) { // five bits containing a negative value
            
                let byte = MsgpackHeader.negativeFixnum
                .merge(additionalInformation: UInt8(bitPattern: Int8(self)).bigEndian)!
            
                return Data([byte])
                
            }
        }
        
        // uint8
        if let uint8Value = UInt8(exactly: self) {
            
            // if the value can be represented a UInt8
            // its also encodable as uint 8
            
            // header + one unsigned byte
            return Data([ MsgpackHeader.uint8.rawValue,
                          uint8Value.bigEndian ])
        }
        
        // int8
        if let int8Value = Int8(exactly: self) {
            
            // header + one signed byte
            return Data([ MsgpackHeader.int8.rawValue,
                          UInt8(bitPattern: int8Value).bigEndian ])
        }
        
        // uint16
        if let uint16Value = UInt16(exactly: self) {
            
            let bigEndian = uint16Value.bigEndian
            let bytes = breakUpUInt16ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.uint16.rawValue,
                           bytes: bytes)
        }
        
        // int16
        if let int16Value = Int16(exactly: self) {
            
            let bigEndian = UInt16(bitPattern: int16Value).bigEndian
            let bytes = breakUpUInt16ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.int16.rawValue,
                           bytes: bytes)
        }
        
        // uint32
        if let uint32Value = UInt32(exactly: self) {
            
            let bigEndian = uint32Value.bigEndian
            let bytes = breakUpUInt32ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.uint32.rawValue,
                           bytes: bytes)
        }
        
        // int32
        if let int32Value = Int32(exactly: self) {
            
            let bigEndian = UInt32(bitPattern: int32Value).bigEndian
            let bytes = breakUpUInt32ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.int32.rawValue,
                           bytes: bytes)
        }
        
        // uint64
        if let uint64Value = UInt64(exactly: self) {
            
            let bigEndian = uint64Value.bigEndian
            let bytes = breakUpUInt64ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.uint64.rawValue,
                           bytes: bytes)
        }
        
        // int64
        if let int64Value = Int64(exactly: self) {
            
            let bigEndian = UInt64(bitPattern: int64Value).bigEndian
            let bytes = breakUpUInt64ToBytes(bigEndian)
            
            return combine(header: MsgpackHeader.int64.rawValue,
                           bytes: bytes)
            
        }
        
        // else
        // this sould never happen unless the code above is errornous
        preconditionFailure("Numeral value exceeded legitimate bounds and could therfor not be encoded.")
        
    }
    
}
