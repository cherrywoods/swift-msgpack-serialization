//
//  DecodingUtilities.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 12.11.17.
//

import Foundation

// MARK: - errors

/// throws MsgpackError.invalidMsgpack if value if not accessable on the given RawMsgpack
func isValid(_ msgpack: RawMsgpack, index: Data.Index) throws {
    guard msgpack.isAccessable(index: index) else {
        throw MsgpackError.invalidMsgpack
    }
}

// MARK: - combining UInts

func combineUInt16(from data: Data) -> UInt16 {
    return combineUInt16(from: data, startIndex: data.startIndex)
}

func combineUInt16(from data: Data, startIndex index: Data.Index) -> UInt16 {
    
    let byte1 = data[index + 0]
    let byte2 = data[index + 1]
    
    let part1 = UInt16(byte1) << 8
    let part2 = UInt16(byte2)
    
    return part1 | part2
    
}

func combineUInt32(from data: Data) -> UInt32 {
    return combineUInt32(from: data, startIndex: data.startIndex)
}

func combineUInt32(from data: Data, startIndex index: Data.Index) -> UInt32 {
    
    let byte1 = data[index + 0]
    let byte2 = data[index + 1]
    let byte3 = data[index + 2]
    let byte4 = data[index + 3]
    
    let part1 = UInt32(byte1) << 24
    let part2 = UInt32(byte2) << 16
    let part3 = UInt32(byte3) << 8
    let part4 = UInt32(byte4)
    
    return part1 | part2 | part3 | part4
    
}

func combineUInt64(from data: Data) -> UInt64 {
    return combineUInt64(from: data, startIndex: data.startIndex)
}

func combineUInt64(from data: Data, startIndex index: Data.Index = 0) -> UInt64 {
    
    let byte1 = data[index + 0]
    let byte2 = data[index + 1]
    let byte3 = data[index + 2]
    let byte4 = data[index + 3]
    let byte5 = data[index + 4]
    let byte6 = data[index + 5]
    let byte7 = data[index + 6]
    let byte8 = data[index + 7]
    
    let part1 = UInt64(byte1) << 56
    let part2 = UInt64(byte2) << 48
    let part3 = UInt64(byte3) << 40
    let part4 = UInt64(byte4) << 32
    let part5 = UInt64(byte5) << 24
    let part6 = UInt64(byte6) << 16
    let part7 = UInt64(byte7) << 8
    let part8 = UInt64(byte8)
    
    return part1 | part2 | part3 | part4 | part5 | part6 | part7 | part8
    
}
