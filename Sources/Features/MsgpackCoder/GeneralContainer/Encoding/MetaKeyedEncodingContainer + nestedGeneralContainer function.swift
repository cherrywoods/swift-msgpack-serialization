//
//  MetaKeyedEncodingContainer + nestedGeneralContainer function.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 12.01.18.
//

import Foundation
import MetaSerialization

public extension MetaKeyedEncodingContainer {
    
    public func nestedGeneralContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> GeneralEncodingContainer where NestedKey : CodingKey {
        
        let nestedMeta = (self.reference.coder.translator as! MsgpackTranslator).generalContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        return GeneralEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
}
