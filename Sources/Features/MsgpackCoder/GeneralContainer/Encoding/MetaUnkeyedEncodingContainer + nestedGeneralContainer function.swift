//
//  MetaUnkeyedEncodingContainer + nestedGeneralContainer function.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 12.01.18.
//

import Foundation
import MetaSerialization

public extension MetaUnkeyedEncodingContainer {
    
    public func nestedGeneralContainer<NestedKey>(keyedBy keyType: NestedKey.Type) throws -> GeneralEncodingContainer where NestedKey : CodingKey {
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        // at this point, count is the index at which nestedMeta will be inserted
        self.codingPath.append( IndexCodingKey(intValue: self.count)! )
        defer { self.codingPath.removeLast() }
        
        let nestedMeta = (self.reference.coder.translator as! MsgpackTranslator).generalContainerMeta()
        
        self.referencedMeta.append(element: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        return GeneralEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
}
