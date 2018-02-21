//
//  Convert Date to extension value.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 14.02.18.
//

import Foundation

extension Date {
    
    // MARK: encode

    func toMsgpackExtensionValue() -> MsgpackExtensionValue {
        
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
            var seconds = UInt64( timeInterval.rounded(.down) )
            var nanoSeconds = UInt32( timeInterval - TimeInterval(seconds) )
            
            // msgpack sets the condition, that "nanoseconds must not be larger than 999999999".
            while nanoSeconds > 999999999 {
                // if nanoSeconds are larger, we add 1 to seconds and lower nanoSeconds by 1000000000
                nanoSeconds -= 1000000000
                seconds += 1
            }
            
            // check whether seconds fit in the available space of a timestamp 64
            if 0 < seconds && seconds < UInt64(1<<34) {
                
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
        
        // data may be 32, 64 or 96 bytes long.
        if data.count == 32 {
            
            // timestamp 32
            
            // the 32 bit data value carries the seconds since 1.1.1970 00:00:00 UTC
            let secondsSince1970 = combineUInt32(from: data, startIndex: data.startIndex)
            
            // all UInt32 values can be represented as Double
            let timeInterval = TimeInterval(exactly: secondsSince1970)!
            
            return Date(timeIntervalSince1970: timeInterval)
            
        } else if data.count == 64 {
            
            // timestamp 64
            
            // the first 30 bits carry a nanoseconds value
            // and the remaining 34 bits carry the seconds since 1.1.1970 00:00:00 UTC
            let numericValueOfWholeData = combineUInt64(from: data, startIndex: data.startIndex)
            // take just the the first 30 bits
            // and shift them down 34 bits
            // now, nanoSeconds is the number that was written to the first 30 bits
            let nanoSeconds = numericValueOfWholeData & 0xfffffffc_00000000 >> 34
            // take just the lower 34 bits
            let secondsSince1970 = numericValueOfWholeData & 0x00000003_ffffffff
            
            // also "UInt34" and "UInt30" values can be represented as Double
            let secondsAsTI = TimeInterval(exactly: secondsSince1970)!
            let nanosAsTI = TimeInterval(exactly: nanoSeconds)!
            
            // TODO: check whether the following code really works!
            
            // divide nanosAsTI by 2^30 to shift the value behind the decimal dot
            let timeInterval = secondsAsTI + nanosAsTI/Double(1<<30)
            
            return Date(timeIntervalSince1970: timeInterval)
            
        } else if data.count == 96 {
            
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
            let timeIntervalSince1970 = (secondsAsTI + 62135596800.0) + nanosAsTI/Double(1<<32)
            
            return Date(timeIntervalSince1970: timeIntervalSince1970)
            
        } else {
            // unsupported/invalid msgpack code
            throw MsgpackError.invalidMsgpack
        }
        
    }
    
}

