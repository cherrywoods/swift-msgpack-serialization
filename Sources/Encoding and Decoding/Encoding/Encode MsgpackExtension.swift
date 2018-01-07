//
//  Encode MsgpackExtension.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation
import MetaSerialization

extension MsgpackExtensionValue {
    
    func encodeToMsgpack() -> Data {
        
        switch self.data.count {
        case 1:
            // fixext1
            return combineExtension(header: MsgpackHeader.fixext1.rawValue,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 2:
            // fixext2
            return combineExtension(header: MsgpackHeader.fixext2.rawValue,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 4:
            // fixext4
            return combineExtension(header: MsgpackHeader.fixext4.rawValue,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 8:
            // fixext2
            return combineExtension(header: MsgpackHeader.fixext8.rawValue,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 16:
            // fixext2
            return combineExtension(header: MsgpackHeader.fixext16.rawValue,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 0..<(1<<8):
            // ext8
            return combineExtension(header: MsgpackHeader.ext8.rawValue,
                                    length: [UInt8(self.data.count).bigEndian],
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        case 0..<(1<<16):
            // ext16
            let lengthBytes = breakUpUInt16ToBytes(UInt16(self.data.count).bigEndian)
            return combineExtension(header: MsgpackHeader.ext16.rawValue,
                                    length: lengthBytes,
                                    code: self.typeCode.bigEndian,
                                    furtherData: self.data)
        default:
            
            // on 32-bit platforms, Int is just 32 bits large
            // and therfor 1<<32 would not fit in one Int
            // and could trigger a strange runtime error on those platforms
            if let uint32Length = UInt32(exactly: self.data.count ) {
                
                // ext32
                let lengthBytes = breakUpUInt32ToBytes(uint32Length.bigEndian)
                return combineExtension(header: MsgpackHeader.ext32.rawValue,
                                        length: lengthBytes,
                                        code: self.typeCode.bigEndian,
                                        furtherData: self.data)
                
            } else {
                // This should never happen
                preconditionFailure("Data exceeded legitimate length and could therfor not be encoded.")
            }
        }
        
    }
    
}
