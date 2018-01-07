//
//  Encode Dictionary java compatibily.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization
import NoSerialization

internal struct JavaCompatibel {
    
    static func encodeDictionary(_ dictionary: Dictionary<AnyHashable, Any>, with options: Configuration) throws -> MapMeta {
        
        let mapMeta = MapMeta()
        
        let serialization = ToMetaSerialization(translator: MsgpackTranslator(with: options))
        var counter = 0
        
        for (key, value) in dictionary {
            
            let keyC = EncodableContainer(value: key as! Encodable)
            let valueC = EncodableContainer(value: value as! Encodable)
            
            // encode key and value to Meta
            let keyMeta = try serialization.encode(keyC)
            let valueMeta = try serialization.encode(valueC)
            
            // insert metas into mapMeta
            mapMeta.add(key: keyMeta, value: valueMeta)
            
            counter += 1
            
        }
        
        return mapMeta
        
    }
    
}
