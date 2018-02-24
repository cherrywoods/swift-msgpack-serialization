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
            
            // timestamp 32
            
            let timestampData = Data( breakUpUInt32ToBytes(uint32Interval) )
            // data is 4 bytes long, so init won't throws
            return try! MsgpackExtensionValue(type: PredefinedExtensionType.timeStamp.rawValue,
                                              data: timestampData)
            
        } else {
            
            // preambel for timestamp 64 and 96
            
            // round toward zero to get the seconds part
            let seconds = timeInterval.rounded(.towardZero)
            
            // to get the nano seconds, calculate the decimal part and multiply it by 1_000_000_000
            // the decimal part of timeInterval may not be preciser than nano seconds
            // this is the only condition. due to the representation format of dates in swift,
            // it is not possible that nano seconds is larger than 999999999 (a condition msgpack sets)
            guard let nanoSeconds = UInt32(exactly: ( timeInterval - TimeInterval(seconds) ) * 1_000_000_000) else {
                throw MsgpackError.dateUnconvertibleToTimestamp
            }
            
            // check whether seconds fit in the available space of a timestamp 64
            if 0 <= seconds && seconds < Double(1<<34) {
                
                // timestamp 64
                
                // can be converted due to the previously checked conditions
                // and the construction of seconds
                let secs = UInt64(seconds)
                
                // nanoseconds should be filled into 30 bits and seconds into 34
                // (but the seconds are already just in 34 bits, because seconds is smaller than 1<<34)
                let nanos = nanoSeconds & 0xfffffffc // cut away the smallest two bits
                
                // combine nano seconds and seconds into one UInt64
                let combined = UInt64( nanos ) << 34 | secs
                let timestampData = Data( breakUpUInt64ToBytes(combined) )
                
                // data is 8 bytes long, so init won't throw
                return try! MsgpackExtensionValue(type: PredefinedExtensionType.timeStamp.rawValue,
                                                  data: timestampData)
                
            } else {
                
                // timestamp 96
                
                // we still need to check that seconds can be represented by Int64
                guard let secs = Int64(exactly: seconds) else {
                    throw MsgpackError.dateUnconvertibleToTimestamp
                }
                
                let nanosecondsBytes = breakUpUInt32ToBytes(nanoSeconds)
                let secondsBytes = breakUpUInt64ToBytes( UInt64(bitPattern: secs) )
                
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
            let timeIntervalSince1970 = secondsAsTI + (nanosAsTI * 0.000_000_001)
            
            return Date(timeIntervalSince1970: timeIntervalSince1970)
            
        } else {
            // unsupported/invalid msgpack code
            throw MsgpackError.invalidMsgpack
        }
        
    }
    
}

