//
//  Convert Date to extension value.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 14.02.18.
//

import Foundation

extension Date {
    
    // MARK: encode

    func toMsgpackExtensionValue() throws -> MsgpackExtensionValue {
        
        // encode as timestamp
        
        let timeInterval = self.timeIntervalSince1970
        
        if let uint32Interval = UInt32(exactly: timeInterval) {
            
            // the date can be represented as timestamp 32
            let timestampData = Data( breakUpUInt32ToBytes(uint32Interval) )
            // data is 4 bytes long, so init won't throws
            return try! MsgpackExtensionValue(type: PredefinedExtensionType.timeStamp.rawValue,
                                              data: timestampData)
            
        } else {
            
            // timeInterval is in seconds
            // cutting away the part smaller than 1, seconds stay
            let seconds = UInt64( timeInterval.rounded(.down) )
            // to get the nano seconds, calculate the decimal part and multiply by 1_000_000_000
            guard let nanoSeconds = UInt32(exactly: ( timeInterval - TimeInterval(seconds) ) * 1_000_000_000) else {
                // dates may not be preciser than nano seconds
                throw MsgpackError.dateWasTooPrecise
            }
            
            // check whether seconds fit in the available space of a timestamp 64
            if 0 <= seconds && seconds < UInt64(1<<34) {
                
                // can be represented as timestamp 64
                
                // nanoseconds should be filled into 30 bits and seconds into 34
                // (but the seconds are already just in 34 bits, because seconds is smaller than 1<<34)
                let nanos = nanoSeconds & 0xfffffffc // cut away the smallest two bits
                
                // combine nano seconds and seconds into one UInt64
                let nanosAndSeconds = UInt64( nanos ) << 34 | seconds
                
                let timestampData = Data( breakUpUInt64ToBytes(nanosAndSeconds) )
                
                // data is 8 bytes long, so init won't throws
                return try! MsgpackExtensionValue(type: PredefinedExtensionType.timeStamp.rawValue,
                                                  data: timestampData)
                
            } else {
                
                // timestamp 96
                
                // recalculate the base, now relative to 1.1.1 00:00:00 (UTC)
                // 1.1.1970 00:00:00 relative to 1.1.1 00:00:00 is 62135596800
                
                let secondsRelativeToYear1 = seconds-62135596800
                
                let nanosecondsBytes = breakUpUInt32ToBytes(nanoSeconds)
                let secondsBytes = breakUpUInt64ToBytes(secondsRelativeToYear1)
                
                // data is 12 bytes long, so init won't throws
                return try! MsgpackExtensionValue(type: PredefinedExtensionType.timeStamp.rawValue,
                                                  data: Data( nanosecondsBytes + secondsBytes ))
                
            }
            
        }
        
    }
    
    // MARK: decode
    
    static func fromTimestampExtension(_ extensionValue: MsgpackExtensionValue,
                                       with options: Configuration) throws -> Date {
        
        // ignore type code, there should already have been a check
        // that it is the right one
        
        let data = extensionValue.data
        
        // data may be 4, 8 or 12 bytes long.
        if data.count == 4 {
            
            // timestamp 32
            
            // the 32 bit data value carries the seconds since 1.1.1970 00:00:00 UTC
            let secondsSince1970 = combineUInt32(from: data, startIndex: data.startIndex)
            
            // all UInt32 values can be represented as Double
            let timeInterval = TimeInterval(exactly: secondsSince1970)!
            
            return Date(timeIntervalSince1970: timeInterval)
            
        } else if data.count == 8 {
            
            // timestamp 64
            
            // the first 30 bits carry a nanoseconds value
            // and the remaining 34 bits carry the seconds since 1.1.1970 00:00:00 UTC
            let numericValueOfWholeData = combineUInt64(from: data, startIndex: data.startIndex)
            
            let nanoSeconds = (numericValueOfWholeData & 0xfffffffc_00000000) >> 34
            let secondsSince1970 = numericValueOfWholeData & 0x00000003_ffffffff
            
            let secondsAsTI = TimeInterval(exactly: secondsSince1970)!
            let nanosAsTI = TimeInterval(exactly: nanoSeconds)!
            
            let timeInterval = secondsAsTI + nanosAsTI * 0.000_000_001
            
            return Date(timeIntervalSince1970: timeInterval)
            
        } else if data.count == 12 {
            
            // timestamp 96
            
            // the first 32 bits (4 bytes)
            let nanoSeconds = combineUInt32(from: data, startIndex: data.startIndex)
            // the remaining 64 bits (8 bytes)
            let secondsSinceYear1 = Int64(bitPattern: combineUInt64(from: data, startIndex: data.startIndex+4))
            
            guard let secondsAsTI = TimeInterval(exactly: secondsSinceYear1), let nanosAsTI = TimeInterval(exactly: nanoSeconds) else {
                // both values need to be representatble as Double
                // (nanoSeconds is always convertible, but code is more compact this way)
                // TODO: decode to special type Timestamp
                throw MsgpackError.timestampUnconvertibleToDate
            }
            
            // 62135596800 is the 1.1.1970 relative to the 1.1.1 (both at 00:00:00, both UTC)
            let timeIntervalSince1970 = (secondsAsTI + 62135596800.0) + (nanosAsTI * 0.000_000_001)
            
            return Date(timeIntervalSince1970: timeIntervalSince1970)
            
        } else {
            // unsupported/invalid msgpack code
            throw MsgpackError.invalidMsgpack
        }
        
    }
    
}

