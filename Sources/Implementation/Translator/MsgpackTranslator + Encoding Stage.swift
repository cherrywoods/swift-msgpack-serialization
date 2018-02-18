//
//  MsgpackTranslator + EncodingStage.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//

import Foundation
import MetaSerialization
import MessagePack

extension MsgpackTranslator {
    
    func encode<Raw>(_ meta: Meta) throws -> Raw {
        
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
        
        switch Raw.self {
        case is Data.Type:
            
            return try encodeToData(with: self.optionSet, meta: meta) as! Raw
            
        case is MessagePackValue.Type:
            
            return try encodeToMessagePackValue(with: self.optionSet, meta: meta) as! Raw
            
        default:
            preconditionFailure("Unsupported Raw type \(Raw.self)")
        }
        
    }
    
}
