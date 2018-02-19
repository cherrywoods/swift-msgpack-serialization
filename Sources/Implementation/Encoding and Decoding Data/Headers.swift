//
//  Headers.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation

internal enum MsgpackHeader: UInt8 {
    
    // MARK: - nil
    case nilHeader              = 0b11000000
    
    // MARK: - Bool
    case falseHeader            = 0b11000010
    case trueHeader             = 0b11000011
    
    // MARK: - int
    case positiveFixnum         = 0b0_0000000 // the real header is 0, the remaining 0s are there as placeholders for the numeral value, that is added using |
    case negativeFixnum         = 0b111_00000 // header is just 111
    case uint8                  = 0b11001100
    case uint16                 = 0b11001101
    case uint32                 = 0b11001110
    case uint64                 = 0b11001111
    case int8                   = 0b11010000
    case int16                  = 0b11010001
    case int32                  = 0b11010010
    case int64                  = 0b11010011
    
    // MARK: - float
    case float32                = 0b11001010
    case float64                = 0b11001011
    
    // MARK: - str
    case fixstr                 = 0b101_00000 // header is just 101
    case str8                   = 0b11011001
    case str16                  = 0b11011010
    case str32                  = 0b11011011
    
    // MARK: - bin
    case bin8                   = 0b11000100
    case bin16                  = 0b11000101
    case bin32                  = 0b11000110
    
    // MARK: - array
    case fixarray               = 0b1001_0000 // header's just 1001
    case array16                = 0b11011100
    case array32                = 0b11011101
    
    // MARK: - map
    case fixmap                 = 0b1000_0000 // header's just 1000
    case map16                  = 0b11011110
    case map32                  = 0b11011111
    
    // MARK: - ext
    case fixext1                = 0b11010100
    case fixext2                = 0b11010101
    case fixext4                = 0b11010110
    case fixext8                = 0b11010111
    case fixext16               = 0b11011000
    case ext8                   = 0b11000111
    case ext16                  = 0b11001000
    case ext32                  = 0b11001001
    
    // MARK: FormatFamily
    
    enum Family {
        case `nil`
        case bool
        case int
        case float
        case str
        case bin
        case ext
        case array
        case map
    }
    
    var formatFamily: Family {
        
        switch(self) {
            
        case .nilHeader:
            return .nil
            
        case .trueHeader, .falseHeader:
            return .bool
            
        case .positiveFixnum, .negativeFixnum, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64:
            return .int
            
        case .float32, .float64:
            return .float
            
        case .str8, .str16, .str32, .fixstr:
            return .str
            
        case .bin8, .bin16, .bin32:
            return .bin
            
        case .fixarray, .array16, .array32:
            return .array
            
        case .fixmap, .map16, .map32:
            return .map
            
        case .fixext1, .fixext2, .fixext4, .fixext8, .fixext16, .ext8, .ext16, .ext32:
            return .ext
            
        }
        
    }
    
    // MARK: length class
    
    enum LengthClass {
        
        /// header has no further data
        case no
        
        /// expresses that a certain header has a clear fix length (specified by the associated value)
        case fix(length: FixLength)
        enum FixLength {
            case contained7Bits
            case contained5Bits
            case oneByte
            case twoBytes
            case fourBytes
            case eightBytes
            case sixteenBytes
        }
        
        /// expresses that a header contains a length value in the lower 5 bits
        case fixContained5Bits
        /// expresses that a header contains a length value in the lower 4 bits
        case fixContained4Bits
        /// header is accompanied by a single length byte
        case oneByte
        /// header is accompanied by two bytes of length information
        case twoBytes
        /// header is accompanied by four bytes of length information
        case fourBytes
    }
    
    var lengthClass: LengthClass {
        
        switch(self) {
            
        // no further data
        case .nilHeader, .trueHeader, .falseHeader:
            return .no
            
        // fix with a fix length
        case .positiveFixnum:                       return .fix(length: .contained7Bits)
        case .negativeFixnum:                       return .fix(length: .contained5Bits)
        case .fixext1, .uint8, .int8:               return .fix(length: .oneByte)
        case .fixext2, .uint16, .int16:             return .fix(length: .twoBytes)
        case .fixext4, .uint32, .int32, .float32:   return .fix(length: .fourBytes)
        case .fixext8, .uint64, .int64, .float64:   return .fix(length: .eightBytes)
        case .fixext16:                             return .fix(length: .sixteenBytes)
            
        // fix contained length
        case .fixstr:               return .fixContained5Bits
        case .fixarray, .fixmap:    return .fixContained4Bits
            
        // one length byte
        case .str8, .bin8, .ext8:
            return .oneByte
            
        // two length bytes
        case .str16, .bin16, .array16, .map16, .ext16:
            return .twoBytes
            
        // four length bytes
        case .str32, .bin32, .array32, .map32, .ext32:
            return .fourBytes
            
        }
        
    }
    
    // MARK: init with raw
    
    /**
     Inits with the given byte raw value
     Returns nil, if the header is unknown
     */
    init?(headerByte: UInt8) {
        
        let rawValue: UInt8
        
        // handle special fix headers
        
        // check the first bit
        if MsgpackHeader.positiveFixnum.rawValue == headerByte & Mask.firstBit {
            // positive fixnum
            rawValue = MsgpackHeader.positiveFixnum.rawValue
            
        // check first three bits
        } else if MsgpackHeader.negativeFixnum.rawValue == headerByte & Mask.firstThreeBits {
            // negative fixnum
            rawValue = MsgpackHeader.negativeFixnum.rawValue
        } else if MsgpackHeader.fixstr.rawValue == headerByte & Mask.firstThreeBits {
            // fix str
            rawValue = MsgpackHeader.fixstr.rawValue
            
        // check first four bits
        } else if MsgpackHeader.fixarray.rawValue == headerByte & Mask.firstFourBits {
            // fix array
            rawValue = MsgpackHeader.fixarray.rawValue
        } else if MsgpackHeader.fixmap.rawValue == headerByte & Mask.firstFourBits {
            // fix map
            rawValue = MsgpackHeader.fixmap.rawValue
            
        // full byte values
        } else {
            rawValue = headerByte
        }
        
        // returns nil, if the header is unknown
        self.init(rawValue: rawValue)
        
    }
    
    // MARK: supporting fuctions
    
    /**
     extracts additional information (typically a length) from a header byte, if this header supports it, otherwise nil.
     
     positiveFixnum and negativeFixnum do not support additional information extraction. Use the whole byte value passed to you instead, the header does not change the value in these cases.
     fixstr, fixarray and fiymap support extraction of additional information
     */
    func extractAdditionalInformation(fromHeaderByte byte: UInt8) -> UInt8? {
        
        switch self {
        case .fixstr:
            // the first three bits are the header
            // clear that bits
            return byte & ~Mask.firstThreeBits
        case .fixarray, .fixmap:
            // first four bits need to be cleared
            return byte & ~Mask.firstFourBits
        default:
            // the other headers do not support extraction
            return nil
        }
        
    }
    
    /**
     merges additional information (typically a length) to a header byte, if this header supports it, otherwise nil.
     
     The additionalInformation byte will be enshortend to the legitimate bit lenth.
     
     positiveFixnum (7 bit) and negativeFixnum (5 bit), fixstr (5 bit), fixarray (4 bit) and fixmap (4 bit) support merging additional information
     */
    func merge(additionalInformation byte: UInt8) -> UInt8? {
        
        switch self {
        case .positiveFixnum:
            // first bit is header, the remaining bits are available
            return self.rawValue | (~Mask.firstBit & byte)
        case .negativeFixnum, .fixstr:
            // first three bits occupied by the header
            return self.rawValue | (~Mask.firstThreeBits & byte)
        case .fixarray, .fixmap:
            // first four bits occupied
            return self.rawValue | (~Mask.firstFourBits & byte)
        default:
            // no additional information supported
            return nil
        }
        
    }
    
}
