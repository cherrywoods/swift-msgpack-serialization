//
//  MsgpackTranslator + unwrap.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization

extension MsgpackTranslator {
    
    func unwrap<T>(meta: Meta, toType type: T.Type) throws -> T? {
        
        // Nil
        // NilMeta will not reach here
        
        // Bool
        // using as? will produce nil,
        // if T is not the expected type (Bool here)
        if meta is SimpleGenericMeta<Bool> {
            
            return meta.get() as? T
        
        // Ints
        // unwrap will check for the type of T
        // and return nil, if T is not an Int
        } else if let intMeta = meta as? IntFormatMeta<Int> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<UInt> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<Int8> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<UInt8> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<Int16> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<UInt16> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<Int32> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<UInt32> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<Int64> {
            return try unwrap(intFormatMeta: intMeta)
        } else if let intMeta = meta as? IntFormatMeta<UInt64> {
            return try unwrap(intFormatMeta: intMeta)
           
        // Float and Double
        // also here, unwrap will check for T
        } else if let floatMeta = meta as? FloatFormatMeta<Float> {
            return try unwrap(floatFormatMeta: floatMeta)
        } else if let doubleMeta = meta as? FloatFormatMeta<Double> {
            return try unwrap(floatFormatMeta: doubleMeta)
            
        // String
        } else if meta is SimpleGenericMeta<String> {
            
            /**
             Adding decoding from strings to Bool, Float, Double, Ints and UInts
             Because msgpack-java encodes all keys as strings by default
             */
            let string = meta.get() as! String
            return string as? T ?? unwrap(string: string)
            
        // Data
        } else if meta is SimpleGenericMeta<Data> {
            
            // T might be eigther Data or [UInt8]
            // Data is no problem
            // because we store binary data as Data internally
            // but therefor [UInt8] needs to be converted
            
            if T.self == [UInt8].self {
                
                return (meta.get() as! Data).map { return $0 } as? T
                
            }
            
            return meta.get() as? T
            
        // Extension
        } else if meta is SimpleGenericMeta<MsgpackExtensionValue> {
            
            return meta.get() as? T
            
        // Date decoded with TimeStamp
        } else if meta is SimpleGenericMeta<Date> {
            
            // date might still decode itself
            // this code is just for encoded timestamps
            
            return meta.get() as? T
            
        // something strange
        } else {
            
            return nil
            
        }
        
    }
    
    fileprivate func unwrap<BI, T>(intFormatMeta intMeta: IntFormatMeta<BI>) throws -> T? {
        
        let allowLoosyConversion = self.optionSet.allowLoosyNumberConversion
            
        // cast to the correct return type
        if        T.self == Int.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Int?)    as! T?
        } else if T.self == UInt.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as UInt?)   as! T?
        } else if T.self == Int8.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Int8?)   as! T?
        } else if T.self == UInt8.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as UInt8?)  as! T?
        } else if T.self == Int16.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Int16?)  as! T?
        } else if T.self == UInt16.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as UInt16?) as! T?
        } else if T.self == Int32.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Int32?)  as! T?
        } else if T.self == UInt32.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as UInt32?) as! T?
        } else if T.self == Int64.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Int64?)  as! T?
        } else if T.self == UInt64.self {
            return try (intMeta.castTo(allowLoosyConversion: allowLoosyConversion) as UInt64?) as! T?
        } else {
            return nil
        }
        
    }
    
    fileprivate func unwrap<BFP, T>(floatFormatMeta floatMeta: FloatFormatMeta<BFP>) throws -> T? {
        
        let allowLoosyConversion = self.optionSet.allowLoosyFloatingPointNumberConversion
        
        if        T.self == Float.self {
            return try floatMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Float? as! T?
        } else if T.self == Double.self {
            return try floatMeta.castTo(allowLoosyConversion: allowLoosyConversion) as Double? as! T?
        } else {
            return nil
        }
        
    }
    
    fileprivate func unwrap<T>(string: String) -> T? {
        
        if        T.self == Bool.self {
            return Bool(string) as! T?
        } else if T.self == Float.self {
            return Float(string) as! T?
        } else if T.self == Double.self {
            return Double(string) as! T?
        } else if T.self == Int.self {
            return Int(string) as! T?
        } else if T.self == UInt.self {
            return UInt(string) as! T?
        } else if T.self == Int8.self {
            return Int8(string) as! T?
        } else if T.self == UInt8.self {
            return UInt8(string) as! T?
        }  else if T.self == Int16.self {
            return Int16(string) as! T?
        } else if T.self == UInt16.self {
            return UInt16(string) as! T?
        } else if T.self == Int32.self {
            return Int32(string) as! T?
        } else if T.self == UInt32.self {
            return UInt32(string) as! T?
        } else if T.self == Int64.self {
            return Int64(string) as! T?
        } else if T.self == UInt64.self {
            return UInt64(string) as! T?
        } else {
            return nil
        }
        
    }
    
}
