//
//  Encode Date.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation
import MetaSerialization

extension Date {
    
    func encodeToMsgpack() -> Data {
        
        // encode as timestamp
        
        let timeInterval = self.timeIntervalSince1970
        let timestampExtensionCodeByte = UInt8(bitPattern: PredefinedExtensionType.timeStamp.rawValue )
        
        if let uint32Interval = UInt32(exactly: timeInterval) {
            
            // this makes is simple, the date can be represented as timestamp 32
            let timestampData = Data( breakUpUInt32ToBytes(uint32Interval) )
            return combineExtension(header: MsgpackHeader.fixext4.rawValue,
                                    code: timestampExtensionCodeByte,
                                    furtherData: timestampData)
            
        } else {
            
            // time interval is in seconds
            // cutting away the part smaller than 1, seconds stay
            // the initalizers for floating point values always round (no init(clamping: ))
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
                
                return combineExtension(header: MsgpackHeader.fixext8.rawValue,
                                        code: timestampExtensionCodeByte,
                                        furtherData: timestampData)
                
            } else {
                
                // timestamp 96
                
                // recalculate the base, now relative to 1.1.1 00:00:00 (UTC)
                // 1.1.1970 00:00:00 relative to 1.1.1 00:00:00 is 62135596800
                
                let secondsRelativeToYear1 = seconds-62135596800
                
                let nanosecondsBytes = breakUpUInt32ToBytes(nanoSeconds)
                let secondsBytes = breakUpUInt64ToBytes(secondsRelativeToYear1)
                
                return combineExtension(header: MsgpackHeader.ext8.rawValue,
                                        length: [12],
                                        code: timestampExtensionCodeByte,
                                        furtherData: Data( nanosecondsBytes + secondsBytes ))
                
            }
            
        }
        
    }
    
}
