//
//  GeneralUtilities.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 21.11.17.
//

import Foundation
import MetaSerialization

/**
 Contains mask values used to access certain bits of a byte.
 
 Use your byte & mask to access bits.
 Inverting a mask gives you a mask for all the other bits previously uncovered (inverted firstBit is lowerSevenBits)
 */
struct Mask {
    
    static let firstBit: UInt8          = 0b10000000
    static let firstThreeBits: UInt8    = 0b11100000
    static let firstFourBits: UInt8     = 0b11110000
    
}

/// just a simple wrapper for any encodable with a fix type
struct EncodableContainer: DirectlyEncodable {
    
    let value: Encodable
    
}
