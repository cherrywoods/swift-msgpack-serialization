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
        
        // switch the length class to obtain the first Index of the value data and the length of the length data section
        switch header.lengthClass {
            
        case.no:
            self.firstValueIndex = nil
            self.valueDataLength = nil
        case .fix( let length ):
            switch length {
            case .contained7Bits, .contained5Bits:
                self.firstValueIndex = 0; self.valueDataLength = 1 // value contained in header byte
            case .oneByte:
                self.firstValueIndex = 1; self.valueDataLength = 1 // value after header byte, length fix
            case .twoBytes:
                self.firstValueIndex = 1; self.valueDataLength = 2
            case .fourBytes:
                self.firstValueIndex = 1; self.valueDataLength = 4
            case .eightBytes:
                self.firstValueIndex = 1; self.valueDataLength = 8
            case .sixteenBytes:
                self.firstValueIndex = 1; self.valueDataLength = 16
            }
        case .fixContained5Bits:
            self.firstValueIndex = 1
            self.valueDataLength = Int(header.extractAdditionalInformation(fromHeaderByte: headerByte)!)
        case .fixContained4Bits:
            self.firstValueIndex = 1
            self.valueDataLength = Int(header.extractAdditionalInformation(fromHeaderByte: headerByte)!)
        case .oneByte:
            self.firstValueIndex = 2 // header + length
            self.valueDataLength = Int( data[data.startIndex + 1] )
        case .twoBytes:
            self.firstValueIndex = 3 // length in 2 bytes + header
            self.valueDataLength = Int( combineUInt16(from: data, startIndex: data.startIndex + 1) )
        case .fourBytes:
            self.firstValueIndex = 5 // length in 4 bytes + header
            self.valueDataLength = Int( combineUInt32(from: data, startIndex: data.startIndex + 1) )
        }
        
        // if header is an extension type, extend the calculated length by one byte for the type code
        if header == .fixext1 || header == .fixext2 || header == .fixext4 || header == .fixext8 || header == .fixext16 ||
            header == .ext8 || header == .ext16  || header == .ext32 {
            self.valueDataLength! += 1
        }
        
        // make sure, that data contains the necessary length and value bytes
        // note that this is also the minimum length for arrays and maps
        guard data.count >= (firstValueIndex ?? 0) + (valueDataLength ?? 1) else {
            throw MsgpackError.invalidMsgpack
        }
        
    }
    
    // MARK: access data
    
    /**
     The first index after heder and length section,
     that caontains data of this msgpack value (if this value has further data),
     relative to data.startIndex
     */
    private let firstValueIndex: Data.Index?
    /**
     The lenght of the value section
     */
    let valueDataLength: Int?
    
    /// call this function to ensure, that the subscripts will not produce a crash.
    func isAccessable(index: Data.Index) -> Bool {
        
        guard index>=0 else {
            // no indices below 0! never!
            return false
        }
        
        guard firstValueIndex != nil && valueDataLength != nil else {
            // if there's no data, there's no valid index
            return false
        }
        
        // if index is below valueDataLength + data.startIndex (and > 0 and valueDataLength != nil), then it is valid.
        return index < valueDataLength!
        
    }
    
    /// if this function returns, index is valid.
    private func ensureValdidity(of index: Data.Index) {
        // if index is inaccessable, it is invalid
        precondition(isAccessable(index: index), "Requested data out of range")
    }
    
    /**
     Access a single byte in the value data section
     Will crash the programm, if you access a value out of range
     */
    subscript(index: Data.Index) -> UInt8 {
        
        get {
            ensureValdidity(of: index)
            
            // skip header and length bytes (or not in some special cases)
            // therfor index = 0 refers to the first byte of the value data section
            return data[ data.startIndex + firstValueIndex! + index ]
        }
        
    }
    
    /**
     Access a range of the value data section
     Will crash the programm, if you access values out of range
     */
    subscript(range: Range<Data.Index>) -> Data {
        
        get {
            ensureValdidity(of: range.lowerBound)
            ensureValdidity(of: range.upperBound-1) // upperBound-1 is the last contained value
            
            // recalculate bounds
            let newLowerBound = range.lowerBound + data.startIndex + firstValueIndex!
            let newUpperBound = newLowerBound + range.count
            
            return data[ newLowerBound..<newUpperBound ]
        }
        
    }
    
    /**
     Access the whole value data section.
     - Warning: This value does not work for arrays and maps
     */
    lazy var valueData: Data? = {
        
        guard firstValueIndex != nil && valueDataLength != nil else {
            // .no class header has no value data
            return nil
        }
        
        if !isAccessable(index: firstValueIndex!) {
            // if there's no value at the first index,
            // which may happen, if the length of for example
            // a string was 0, return empty Data.
            // (avoid runtime errors from subscripting data)
            return Data()
        }
        
        return data[data.startIndex + firstValueIndex!..<(data.startIndex + firstValueIndex!+valueDataLength!)]
        
    }()
    
    // MARK: trimming of data segments
    
    /**
     The data from this RawMsgpacks data, that does not belong to the msgpack value at the beginning of the section, if there are any further values
     
     If this msgpack is an array, or map, this variable contains the raw elements of the array or map.
     */
    lazy var remainingData: Data? = {
        
        let firstIndex: Data.Index
        
        // special cases: arrays and maps
        if header.formatFamily == .array || header.formatFamily == .map {
            
            // in this case just remove the header and the length information
            firstIndex = firstValueIndex!
            
        } else {
            
            // the next value starts after the value data section
            // which begins at firstValueIndex and is valueDataLength bytes long
            // therfor the byte firstValueIndex + valueDataLength is not included
            // and belongs to the next mgpack value.
            // if this msgpack section has no further data, the next section begins at 1
            firstIndex = (firstValueIndex ?? 0) + (valueDataLength ?? 1)
            
        }
        
        // it may be, that data contains no further values at all. In this case, return nil
        // drop works relatively to data.startIndex
        return data.count <= firstIndex ? nil : data.dropFirst(firstIndex)
        
    }()
    
}
