//
//  KeyedDecodingContainer + generalContainer function.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 13.01.18.
//

import Foundation
import MetaSerialization

public extension MetaKeyedDecodingContainer {
    
    public func nestedGeneralContainer(forKey key: K) throws -> GeneralDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: key)
        
        // first check whether there's a meta at all for the key
        guard let subMeta = self.referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No container for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // check, wheter subMeta is a MapMeta
        guard let containerSubMeta = subMeta as? MapMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(GeneralDecodingContainer.self, context)
        }
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: containerSubMeta)
        
        return GeneralDecodingContainer(referencing: nestedReference)
        
    }
    
}
