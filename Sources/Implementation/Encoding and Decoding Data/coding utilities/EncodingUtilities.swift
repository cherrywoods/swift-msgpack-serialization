//
//  EncodingUtility.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 11.11.17.
//

import Foundation

// MARK: - failures

internal func metaHadNoValueAtEncodingTime() -> Never {
    preconditionFailure("Meta had no value at encoding time.")
}

// MARK: - break ups

internal func breakUpUInt16ToBytes(_ longValue: UInt16) -> [UInt8] {
    
    let byte1 = UInt8( (longValue >> 8) & 0b11111111 )
    let byte2 = UInt8( (longValue     ) & 0b11111111 )
    
    return [byte1, byte2]
    
}

internal func breakUpUInt32ToBytes(_ longValue: UInt32) -> [UInt8] {
    
    let byte1 = UInt8( (longValue >> 24) & 0b11111111 )
    let byte2 = UInt8( (longValue >> 16) & 0b11111111 )
    let byte3 = UInt8( (longValue >> 8 ) & 0b11111111 )
    let byte4 = UInt8( (longValue      ) & 0b11111111 )
    
    return [byte1, byte2, byte3, byte4]
    
}

internal func breakUpUInt64ToBytes(_ longValue: UInt64) -> [UInt8] {
    
    let byte1 = UInt8( (longValue >> 56) & 0b11111111 )
    let byte2 = UInt8( (longValue >> 48) & 0b11111111 )
    let byte3 = UInt8( (longValue >> 40) & 0b11111111 )
    let byte4 = UInt8( (longValue >> 32) & 0b11111111 )
    let byte5 = UInt8( (longValue >> 24) & 0b11111111 )
    let byte6 = UInt8( (longValue >> 16) & 0b11111111 )
    let byte7 = UInt8( (longValue >> 8 ) & 0b11111111 )
    let byte8 = UInt8( (longValue      ) & 0b11111111 )
    
    return [byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8]
    
}

// MARK: - combines

internal func combine(header: UInt8, length: [UInt8] = [], furtherData: Data) -> Data {
    
    var data = combine(header: header, bytes: length)
    data.append(furtherData)
    return data
    
}

internal func combine(header: UInt8, bytes: [UInt8]) -> Data {
    
    return Data(bytes: [header] + bytes )
    
}

internal func combineExtension(header: UInt8, length: [UInt8] = [], code: UInt8, furtherData: Data) -> Data {
    
    var data = Data( [header] + length + [code] )
    data.append(furtherData)
    return data
    
}
