//
//  Encode MessagePackValue.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 14.02.18.
//

import Foundation
import MetaSerialization
import MessagePack

internal func encodeToMessagePackValue(with options: Configuration, meta: Meta) throws -> MessagePackValue {
    
    // MARK: nil
    if meta is NilMeta { return MessagePackValue.nil }
    
    // MARK: bool
    else if let value = (meta as? SimpleGenericMeta<Bool>)?.value { return MessagePackValue(value) }
    
    // MARK: ints
    else if let value = (meta as? SimpleGenericMeta<Int>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<Int8>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<Int16>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<Int32>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<Int64>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<UInt>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<UInt8>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<UInt16>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<UInt32>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<UInt64>)?.value { return MessagePackValue(value) }
    
    // MARK: floats
    else if let value = (meta as? SimpleGenericMeta<Float>)?.value { return MessagePackValue(value) }
    else if let value = (meta as? SimpleGenericMeta<Double>)?.value { return MessagePackValue(value) }
        
    // MARK: string
    else if let value = (meta as? StringMeta)?.value { return MessagePackValue(value) }
    
    // MARK: binary
    else if let value = (meta as? DataMeta)?.value { return MessagePackValue(value) }
    else if let value = (meta as? ByteArrayMeta)?.value {
        
        let data = Data(bytes: value)
        return MessagePackValue(data)
        
    }
    
    // MARK: date
    else if let date = (meta as? SimpleGenericMeta<Date>)?.value {
        // TODO:
        let extensionValue = try date.toMsgpackExtensionValue()
        return MessagePackValue.extended(extensionValue.type, extensionValue.data)
        
    }
    
    // MARK: ext
    else if let value = (meta as? SimpleGenericMeta<MsgpackExtensionValue>)?.value {
        
        return MessagePackValue.extended(value.type, value.data)
        
    }
    
    // MARK: array meta
    else if let array = (meta as? ArrayUnkeyedContainerMeta)?.value {
        
        let converted = try array.map { try encodeToMessagePackValue(with: options, meta: $0) }
        return MessagePackValue.array(converted)
        
    }
    
    // MARK: map meta
    else if let map = (meta as? MapMeta)?.map {
        
        // encode keys and values
        let converted = try map.map { (key, value) in
            return ( try encodeToMessagePackValue(with: options, meta: key),
                     try encodeToMessagePackValue(with: options, meta: value) )
        }
        return MessagePackValue.map( Dictionary(uniqueKeysWithValues: converted) )
        
    }
    
    // MARK: dictionarys
    else if meta is SkipMeta {
        
        // convert to map meta and then call this function again
        let dictionary = (meta as! SkipMeta).value as! Dictionary<AnyHashable, Encodable>
        let mapMeta = try JavaCompatibel.wrapDictionary(dictionary, with: options)
        
        return try encodeToMessagePackValue(with: options, meta: mapMeta)
        
    } else {
        
        // this indicates an error in this framework, or in meta-serialization
        preconditionFailure("Unsupported meta")
        
    }
    
}
