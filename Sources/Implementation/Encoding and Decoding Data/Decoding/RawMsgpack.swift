//
//  RawMsgpack.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 21.11.17.
//

import Foundation

// this file contains usefull utilities to work with binary msgpack data

/*
 Provides utilities to work with Data that should be parsed as msgpack.
 */
internal class RawMsgpack {
    
    // TODO: dropFirst has O(n) complexity (n = dropped bytes), therefor implementation will get quicker, if we use another index property as startIndex
    
    // MARK: structure
    
    /*
     
     Any valid msgpack data is structured this way:
     
     header byte - length section (optional) - value data (optional)
     
     */
    
    // MARK: properties
    
    /// data's magpack header
    let header: MsgpackHeader
    private var data: Data // the whole binary data this struct is working on
    
    // MARK: init
    
    /**
     Initalize a new RawMsgpack instance with the given data
     
     Will throw:
     - `.invalidMsgpack`, if data had no first byte
     - `.unsupportedMsgpack`, if a header is unknown
     
     - Throws: `MsgpackError.invalidMsgpack` and `MsgpackError.unsupportedMsgpack`
     */
    init(from data: Data) throws {
        
        // data may not be empty
        guard let headerByte = data.first else {
            throw MsgpackError.invalidMsgpack
        }
        
        // match header
        guard let header = MsgpackHeader(headerByte: headerByte) else {
            throw MsgpackError.unknownMsgpack
        }
        
        self.data = data
        self.header = header
        
        // is used to calculate value self.valueDataSection
        // (but can't set directly, because needs to be mutated if header is ext header)
        var valueDataSection: ValueDataSection?
        
        // switch the length class to obtain the first Index of the value data and the length of the length data section
        switch header.lengthClass {
            
        case.no:
            valueDataSection = nil
        case .fix( let length ):
            switch length {
            case .contained7Bits, .contained5Bits:
                // value contained in header byte
                valueDataSection = ValueDataSection(firstIndex: 0, length: 1)
            case .oneByte:
                // value after header byte, length fix
                valueDataSection = ValueDataSection(firstIndex: 1, length: 1)
            case .twoBytes:
                valueDataSection = ValueDataSection(firstIndex: 1, length: 2)
            case .fourBytes:
                valueDataSection = ValueDataSection(firstIndex: 1, length: 4)
            case .eightBytes:
                valueDataSection = ValueDataSection(firstIndex: 1, length: 8)
            case .sixteenBytes:
                valueDataSection = ValueDataSection(firstIndex: 1, length: 16)
            }
        case .fixContained5Bits:
            // the code for 5 and 4 contained bits is the same
            fallthrough
        case .fixContained4Bits:
            valueDataSection = ValueDataSection(firstIndex: 1,
                                                length: Int( header.extractAdditionalInformation(fromHeaderByte: headerByte)! ))
        case .oneByte:
            // value starts after header and length byte
            valueDataSection = ValueDataSection(firstIndex: 2,
                                                length: Int( data[data.startIndex + 1] ))
        case .twoBytes:
            // length in 2 bytes + header
            valueDataSection = ValueDataSection(firstIndex: 3,
                                                length: Int( combineUInt16(from: data, startIndex: data.startIndex + 1) ) )
        case .fourBytes:
            // length in 4 bytes + header
            valueDataSection = ValueDataSection(firstIndex: 5,
                                                length: Int( combineUInt32(from: data, startIndex: data.startIndex + 1) ) )
        }
        
        // if header is an extension type, extend the calculated length by one byte for the type code
        if header.formatFamily == .ext {
            valueDataSection!.length += 1
        }
        
        // make sure, that data contains the necessary length and value bytes
        // note that this is also the minimum length for arrays and maps
        guard data.count >= ( valueDataSection?.sum() ?? 1 ) else {
            throw MsgpackError.invalidMsgpack
        }
        
        self.valueDataSection = valueDataSection
        
    }
    
    // MARK: access data
    
    /// stores the first index and length of the value data section
    private let valueDataSection: ValueDataSection?
    
    /// stores values needed to access the value data section
    private struct ValueDataSection {
        
        /**
         The first index after heder and length section,
         that contains data of this msgpack value (if this value has further data),
         relative to data.startIndex
         */
        var firstIndex: Data.Index
        
        /**
         The lenght of the value section
         */
        var length: Int
        
        /// a utility method that just sums up firstIndex and length
        func sum() -> Int {
            return firstIndex + length
        }
        
    }
    
    /**
     The lenght of the value section
     */
    var valueDataLength: Int? {
        return valueDataSection?.length
    }
    
    /// call this function to ensure, that a subscripts will not produce a crash.
    func isAccessable(index: Data.Index) -> Bool {
        
        guard index>=0 else {
            // no indices below 0! never!
            return false
        }
        
        guard valueData != nil else {
            // if there's no data, there's no valid index
            return false
        }
        
        // if index is below valueDataLength (and > 0 and valueDataLength != nil), then it is valid.
        return index < valueDataLength!
        
    }
    
    /// if this function returns, index is valid.
    private func ensureValdidity(of index: Data.Index) {
        // if index is inaccessable, it is invalid
        precondition(isAccessable(index: index), "Requested data out of range")
    }
    
    /**
     Returns an absolute index that points to the same element, as the given index,
     that is relative to the beginning of the value data section.
     
     valueData must be a non nil to call this method.
     */
    private func shiftIndex(_ index: Data.Index) -> Data.Index {
        return data.startIndex + valueDataSection!.firstIndex + index
    }
    
    /**
     Access a single byte in the value data section
     Will crash the programm, if you access a value out of range
     */
    subscript(index: Data.Index) -> UInt8 {
        
        ensureValdidity(of: index)
        
        // index = 0 refers to the first byte of the value data section
        return data[ shiftIndex(index) ]
        
    }
    
    /**
     Access a range of the value data section
     Will crash the programm, if you access values out of range
     */
    subscript(range: Range<Data.Index>) -> Data {
        
        ensureValdidity(of: range.lowerBound)
        ensureValdidity(of: range.upperBound-1) // upperBound-1 is the last contained value
        
        // recalculate bounds, so that 0..<1 refers to the first byte of the value data section
        return data[ shiftIndex(range.lowerBound) ..< shiftIndex(range.upperBound) ]
        
    }
    
    // valueData and remainingData are not needed for all values.
    // Therefor it makes sence to calculate them lazyly
    
    /**
     Access the whole value data section.
     - Warning: This value does not work for arrays and maps, valueData will be nil
     */
    lazy var valueData: Data? = {
        
        guard valueDataSection != nil else {
            // .no class header has no value data
            return nil
        }
        
        // the value data can't be calculated for arrays and maps
        // without decoding the whole section.
        // Returns nil for those types, because the value that was returned
        // otherwise makes no sence
        guard header.formatFamily != .array && header.formatFamily != .map else {
            return nil
        }
        
        // subscripting empty ranges is possible and returns empty data
        // beyond this, is valueDataLength a valid index (this is checked in the constructor)
        return data[ shiftIndex(0) ..< shiftIndex(valueDataLength!) ]
        
    }()
    
    // MARK: trimming of data segments
    
    /**
     The data from this RawMsgpacks data, that does not belong to the msgpack value at the beginning of the section.
     Returns empty data, there are not further values
     
     If this msgpack is an array, or map, this variable contains the raw elements of the array or map.
     */
    lazy var remainingData: Data = {
        
        // first index on the next value
        let firstIndex: Data.Index
        
        // special cases: arrays and maps
        if header.formatFamily == .array || header.formatFamily == .map {
            
            // in this case just remove the header and the length information
            firstIndex = valueDataSection!.firstIndex
            
        } else {
            
            // because dropFirst is used, firstIndex needs to be firstValueIndex + valueDataLength
            // (do not substract 1, also drop header byte at index 0)
            // if this msgpack section has no further data, the next section begins at 1
            firstIndex = valueDataSection?.sum() ?? 1
            
        }
        
        // drop works relatively to data.startIndex
        // drop also works, if there are less elements than should be dropped
        return data.dropFirst(firstIndex)
        
    }()
    
}
