//
//  MsgpackTranslator + EncodingStage.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization

extension MsgpackTranslator {
    
    func encode<Raw>(_ meta: Meta) throws -> Raw {
        
        precondition(Raw.self == Data.self, "Unsupported Raw type \(Raw.self)")
        return try encode(meta) as! Raw
        
    }
    
    func encode(_ meta: Meta) throws -> Data {
        
        // meta types:
        //  nil (NilMeta)
        //  boolean (SimpleGenericMeta)
        //  integers (SimpleGenericMeta)
        //  float (SimpleGenericMeta)
        //  raw:
        //      string (MsgpackString)
        //      binary (MsgpackBinary)
        //  array (ArrayUnkeyedContainerMeta)
        //  map (MapMeta)
        //  extension (SimpleGenericMeta)
        //  timestamp (SimpleGenericMeta) (optional)
        
        return try MsgpackSerialization.encode(with: self.optionSet, meta: meta)
        
    }
    
}
