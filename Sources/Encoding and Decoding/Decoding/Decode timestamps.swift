//
//  Decode timestamps.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

// decoding code for extension values of the timestamp type

extension RawMsgpack {
    
    func decodeTimestamp(with options: Configuration) throws -> Meta {
        
        guard var data = self.valueData else {
            // asserting that this function was called with a ext header, data may not be nil
            throw MsgpackError.invalidMsgpack
        }
        
        // remove type code (its anyway -1)
        data.removeFirst()
        
        // data may be 32, 64 or 96 bytes long.
        if data.count == 32 {
            // timestamp 32
            
            // the 32 bit data value carries the seconds since 1.1.1970 00:00:00 UTC
            let secondsSince1970 = combineUInt32(from: data, startIndex: data.startIndex)
            
            guard let timeInterval = TimeInterval(exactly: secondsSince1970) else {
                // if the UInt32 value is not expressible as Double
                // (which sould be verry rare) all we can do is throw an error
                // TODO: decode to special type Timestamp
                throw MsgpackError.timestampUnconvertibleToDate
            }
            return SimpleGenericMeta( value: Date(timeIntervalSince1970: timeInterval) )
            
        } else if data.count == 64 {
            // timestamp 64
            
            // the first 30 bits carry a nanoseconds value
            // and the remaining 34 bits carry the seconds since 1.1.1970 00:00:00 UTC
            let numericValueOfWholeData = combineUInt64(from: data, startIndex: data.startIndex)
            // take just the the first 30 bits
            // and shift them down 34 bits
            // now, nanoSeconds is the number that was written to the first 30 bits
            let nanoSeconds = numericValueOfWholeData & 0xfffffffc_00000000 >> 34
            // take jsut the lower 34 bits
            let secondsSince1970 = numericValueOfWholeData & 0x00000003_ffffffff
            
            guard let secondsAsTI = TimeInterval(exactly: secondsSince1970), let nanosAsTI = TimeInterval(exactly: nanoSeconds) else {
                // both values need to be representatble as Double
                throw MsgpackError.timestampUnconvertibleToDate
            }
            
            // TODO: check whether the following code realy works!
            
            // divide nanosAsTI by 2**30 to shift the value behind the decimal dot
            let timeInterval = secondsAsTI + nanosAsTI/Double(1<<30)
            
            return SimpleGenericMeta( value: Date(timeIntervalSince1970: timeInterval) )
            
        } else if data.count == 96 {
            // timestamp 96
            
            // the first 32 bits (4 bytes)
            let nanoSeconds = combineUInt32(from: data, startIndex: data.startIndex)
            // the remaining 64 bits (8 bytes)
            let secondsSinceYear1 = Int64(bitPattern: combineUInt64(from: data, startIndex: data.startIndex+4))
            
            guard let secondsAsTI = TimeInterval(exactly: secondsSinceYear1), let nanosAsTI = TimeInterval(exactly: nanoSeconds) else {
                // both values need to be representatble as Double
                throw MsgpackError.timestampUnconvertibleToDate
            }
            
            // 62135596800 is the 1.1.1970 relative to the 1.1.1 (both at 00:00:00, both UTC)
            let timeIntervalSince1970 = (secondsAsTI + 62135596800.0) + nanosAsTI/Double(1<<32)
            
            return SimpleGenericMeta( value: Date(timeIntervalSince1970: timeIntervalSince1970) )
            
        } else {
            // unsupported/invalid msgpack code
            throw MsgpackError.invalidMsgpack
        }
        
    }
    
}
