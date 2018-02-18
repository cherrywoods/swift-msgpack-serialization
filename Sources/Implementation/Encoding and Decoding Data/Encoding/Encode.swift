//
//  Encode Data.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

internal func encodeToData(with options: Configuration, meta: Meta) throws -> Data {
    
    if meta is NilMeta { // MARK: nil
        
        // nil is just the nil code or header
        return (meta as! NilMeta).encodeToMsgpack()
        
    } else if meta is SimpleGenericMeta<Bool> { // MARK: bool
        
        return (meta as! SimpleGenericMeta<Bool>).value!.encodeToMsgpack()
        
    } else if meta is SimpleGenericMeta<Int> { // MARK: ints
        return (meta as! SimpleGenericMeta<Int>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<Int8> {
        return (meta as! SimpleGenericMeta<Int8>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<Int16> {
        return (meta as! SimpleGenericMeta<Int16>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<Int32> {
        return (meta as! SimpleGenericMeta<Int32>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<Int64> {
        return (meta as! SimpleGenericMeta<Int64>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<UInt> {
        return (meta as! SimpleGenericMeta<UInt>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<UInt8> {
        return (meta as! SimpleGenericMeta<UInt8>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<UInt16> {
        return (meta as! SimpleGenericMeta<UInt16>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<UInt32> {
        return (meta as! SimpleGenericMeta<UInt32>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<UInt64> {
        return (meta as! SimpleGenericMeta<UInt64>).value!.encodeToMsgpack()
        
    } else if meta is SimpleGenericMeta<Float> { // MARK: floats
        return (meta as! SimpleGenericMeta<Float>).value!.encodeToMsgpack()
    } else if meta is SimpleGenericMeta<Double> {
        return (meta as! SimpleGenericMeta<Double>).value!.encodeToMsgpack()
        
    } else if meta is StringMeta { // MARK: string
        return try (meta as! StringMeta).value!.encodeToMsgpack(with: options)
        
    } else if meta is DataMeta { // MARK: binary
        return (meta as! DataMeta).value!.encodeToMsgpack()
        
    } else if meta is ByteArrayMeta { // MARK: binary
        return (meta as! ByteArrayMeta).value!.encodeToMsgpack()
        
    } else if meta is SimpleGenericMeta<Date> { // MARK: data
        
        // encode as MsgpackExtensionValue
        let extensionValue = (meta as! SimpleGenericMeta<Date>).value.toMsgpackExtensionValue()
        return extensionValue.encodeToMsgpack()
        
    } else if meta is SimpleGenericMeta<MsgpackExtensionValue> { // MARK: ext
        return (meta as! SimpleGenericMeta<MsgpackExtensionValue>).value!.encodeToMsgpack()
        
    } else if meta is ArrayUnkeyedContainerMeta { // MARK: array
        return try (meta as! ArrayUnkeyedContainerMeta).encodeToMsgpack(with: options)
        
    } else if meta is MapMeta { // MARK: map
        return try (meta as! MapMeta).encodeToMsgpack(with: options)
        
    } else if meta is SkipMeta {
        
        // encode dictionarys
        let dictionary = (meta as! SkipMeta).value as! Dictionary<AnyHashable, Encodable>
        let finalMeta = try JavaCompatibel.wrapDictionary(dictionary, with: options)
        
        return try finalMeta.encodeToMsgpack(with: options)
        
    } else {
        
        // this indicates an error in this framework, or in meta-serialization
        preconditionFailure("Unsupported meta")
        
    }
    
}
