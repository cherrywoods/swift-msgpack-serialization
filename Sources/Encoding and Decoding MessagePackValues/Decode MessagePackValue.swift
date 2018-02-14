//
//  Decode MessagePackValue.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 14.02.18.
//

import Foundation
import MetaSerialization
import MessagePack

internal func decodeFromMessagePackValue(_ message: MessagePackValue, with configuration: Configuration ) throws -> Meta {
    
    // meta types:
    //  nil -> NilMeta
    //  boolean -> SimpleGenericMeta
    //  integers -> IntFormatMeta
    //  float -> FloatFormatMeta
    //  raw:
    //      string -> SimpleGenericMeta
    //      binary -> SimpleGenericMeta
    //  array -> ArrayUnkeyedContainerMeta
    //  map -> MapMeta
    //  extension -> SimpleGenericMeta
    //  timestamp -> SimpleGenericMeta
    
    switch message {
        
    // MARK: nil
    case .nil:
        return NilMeta.nil
        
    // MARK: bool
    case .bool(let value):
        return SimpleGenericMeta(value: value)
        
    // MARK: int & uint
    case .int(let value):
        return IntFormatMeta(value: value)
    case .uint(let value):
        return IntFormatMeta(value: value)
        
    // MARK: float & double
    case .float(let value):
        return FloatFormatMeta(value: value)
    case .double(let value):
        return FloatFormatMeta(value: value)
        
    // MARK: string
    case .string(let value):
        return SimpleGenericMeta(value: value)
        
    // MARK: binary
    case .binary(let value):
        return SimpleGenericMeta(value: value)
        
    // MARK: array
    case .array(let array):
        
        let unkeyed = ArrayUnkeyedContainerMeta()
        // decode and append each element of value
        try array.forEach { unkeyed.append(element: try decodeFromMessagePackValue($0, with: configuration)) }
        return unkeyed
        
    // MARK: map
    case .map(let map):
        
        let mapMeta = MapMeta()
        // decode keys and values
        try map.forEach { (key, value) in
            mapMeta.add(key: try decodeFromMessagePackValue(key, with: configuration),
                        value: try decodeFromMessagePackValue(value, with: configuration))
            
        }
        return mapMeta
        
    case .extended(let type, let data):
        
        let extensionValue = try MsgpackExtensionValue(type: type, data: data)
        
        // catch timestamps and convert them to Dates
        if type == PredefinedExtensionType.timeStamp.rawValue {
            
            let date = try Date.fromTimestampExtension(extensionValue, with: configuration)
            return SimpleGenericMeta(value: date)
            
        } else {
        
            return SimpleGenericMeta(value: extensionValue)
            
        }
        
    }
    
}
