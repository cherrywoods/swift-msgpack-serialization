//
//  MsgpackTranslator + Decoding Stage.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization

extension MsgpackTranslator {
    
    func decode<Raw>(_ raw: Raw) throws -> Meta {
        
        precondition(Raw.self == Data.self, "Unsupported Raw type")
        
        let data = raw as! Data
        
        // empty data is decoded to nil
        
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
        
        guard !data.isEmpty else {
            // if empty data is passed, we decode to nil
            return NilMeta.nil
            
        }
        
        let raw = try RawMsgpack(from: data)
        return try raw.decode(with: self.optionSet)
        
    }
    
}
