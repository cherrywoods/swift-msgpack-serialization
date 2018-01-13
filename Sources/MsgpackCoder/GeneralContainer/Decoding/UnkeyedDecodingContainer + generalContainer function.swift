//
//  UnkeyedDecodingContainer + generalContainer function.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 13.01.18.
//

import Foundation
import MetaSerialization

public extension MetaUnkeyedDecodingContainer {
    
    public func nestedGeneralContainer() throws -> GeneralDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(GeneralDecodingContainer.self, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let containerSubMeta = subMeta as? MapMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(GeneralDecodingContainer.self, context)
        }
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: containerSubMeta)
        
        return  GeneralDecodingContainer(referencing: nestedReference)
        
    }
    
}
