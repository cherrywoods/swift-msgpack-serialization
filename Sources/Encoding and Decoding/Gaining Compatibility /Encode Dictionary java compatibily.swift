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
        
        let encoder = MsgpackEncoder(with: options)
        
        if options.encodeDictionaryKeysAsStrings {
            
            return try encoder.wrap(StringKeysDictionaryContainer(dictionary: dictionary) ) as! MapMeta
            
        } else {
            
            return try encoder.wrap(DictionaryContainer(dictionary: dictionary)) as! MapMeta
            
        }
        
    }
    
    private struct DictionaryContainer: Encodable {
        
        var dictionary: Dictionary<AnyHashable, Any>
        
        func encode(to encoder: Encoder) throws {
            
            let container = (encoder as! MsgpackEncoder).generalContainer()
            
            for (key, value) in dictionary {
                try (key as! Encodable)._encode(to: container)
                try (value as! Encodable)._encode(to: container)
            }
            
        }
        
    }
    
    private struct StringKeysDictionaryContainer: Encodable {
        
        var dictionary: Dictionary<AnyHashable, Any>
        
        func encode(to encoder: Encoder) throws {
            
            let container = (encoder as! MsgpackEncoder).generalContainer()
            
            for (key, value) in dictionary {
                // convert key to string
                try (key as! LosslessStringConvertible).description._encode(to: container)
                try (value as! Encodable)._encode(to: container)
            }
            
        }
        
    }
    
}

fileprivate extension Encodable {
    
    fileprivate func _encode(to container: GeneralEncodingContainer) throws {
        try container.encode(single: self)
    }
    
}
