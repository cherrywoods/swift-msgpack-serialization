//
//  MsgpackTranslator + Decoding Stage.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization
import MessagePack

extension MsgpackTranslator {
    
    func decode<Raw>(_ raw: Raw) throws -> Meta {
        
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
        
        switch raw {
        case is Data:
            
            let data = raw as! Data
            
            // empty data throws .invalidMsgpack
            guard !data.isEmpty else {
                throw MsgpackError.invalidMsgpack
            }
            
            let raw = try RawMsgpack(from: data)
            return try raw.decode(with: self.optionSet)
            
        case is MessagePackValue:
            
            return try decodeFromMessagePackValue(raw as! MessagePackValue,
                                                  with: self.optionSet)
        default:
            preconditionFailure("Unsupported Raw type \(type(of: raw))")
        }
        
    }
    
}
