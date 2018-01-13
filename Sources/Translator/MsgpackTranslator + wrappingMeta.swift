//
//  MsgpackTranslator + wrapingMeta.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization

extension MsgpackTranslator {
    
    func wrappingMeta<T>(for value: T) -> Meta? {
        
        if value is GenericNil {
            
            // msgpack supports nil
            return NilMeta.nil
            
        } else if value is Bool {
            
            // there's no invalid configuration for a Bool
            return SimpleGenericMeta<T>()
            
        } else if
            value is Int    || value is UInt    ||
            value is Int8   || value is UInt8   ||
            value is Int16  || value is UInt16  ||
            value is Int32  || value is UInt32  ||
            value is Int64  || value is UInt64  {
            
            // note that there is no invalid configuration for an int,
            // that might be detected during the intermediate encoding step
            return SimpleGenericMeta<T>()
            
        } else if value is Float || value is Double {
            
            // both Float (float 32) and Double (float 64) are supported by msgpack
            // (including infinity, negative infinity and NaN)
            return SimpleGenericMeta<T>()
            
        } else if value is String {
            
            // StrFormatFamilyMeta makes sure,
            // that the given Strings are short enough to be converted to msgpack
            // (below 2^32 characters).
            return MsgpackString()
            
        } else if value is Data && self.optionSet.encodeDataAsBinary {
            
            // MsgpackBinaryData makes sure,
            // that the passed Data is short enough to be converted to msgpack
            // (below 2^32 bytes).
            return MsgpackBinaryData()
            
        } else if value is [UInt8] && self.optionSet.encodeDataAsBinary {
            
            // same as with Data
            return MsgpackBinaryByteArray()
            
        } else if value is Date && self.optionSet.convertSwiftDateToMsgpackTimestamp {
            
            // if the option is not set, let Date encode/decode itself
            // encoding by this frmaework will lead to possible loosy conversion
            return SimpleGenericMeta<Date>()
            
        } else if value is MsgpackExtensionValue {
            
            return SimpleGenericMeta<T>()
            
        } else if value is Dictionary<AnyHashable, Any> && self.optionSet.encodeDictionarysJavaCompatibel {
            
            // provide a msgpack-java compatible encoding for dictionarys
            // with this meta, we skip the first encoding process and
            // therefor also the encoding code from Dictionary
            return SkipMeta()
            
        } else if value is EncodableContainer {
            
            // this is necessary because of the type errasure in encoding container
            return wrappingMeta(for: (value as! EncodableContainer).value)
            
        } else {
            
            return nil
            
        }
        
    }
    
    func keyedContainerMeta() -> KeyedContainerMeta {
        return MapMeta()
    }
    
    func generalContainerMeta() -> MapMeta {
        return MapMeta()
    }
    
    // we use the default implementations for the unkeyedContainer method
    
}
