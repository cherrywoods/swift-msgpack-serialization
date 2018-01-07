//
//  SkipMeta.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation
import MetaSerialization

/**
 A Meta for dictionarys to skip the first encoding process
 and encode the keys and values later to apply a special format
 to the encoded data
 */
internal struct SkipMeta: Meta {
    
    // since this dictionary was already encoded once, one may assert that keys and values are Encodables
    var value: Dictionary<AnyHashable, Any>?
    
    func get() -> Any? {
        
        return value
        
    }
    
    mutating func set(value: Any) throws {
        
        self.value = (value as! Dictionary<AnyHashable, Any>)
        
    }
    
}
