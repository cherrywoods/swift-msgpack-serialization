//
//  GeneralEncodingContainer.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 11.01.18.
//

import Foundation
import MetaSerialization

/**
 A container that makes directly encoding arbitrary keyed collections possible.
 */
public class GeneralEncodingContainer {
    
    private var reference: Reference
    private var referencedMeta: MapMeta {
        get {
            return reference.element as! MapMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    public var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - encode
    
    public func encodeNil<Key>(forKey key: Key) throws where Key: Encodable {
        try encode(key: key, value: GenericNil.instance)
    }
    
    public func encode<Key, Value>(key: Key, value: Value) throws where Key: Encodable, Value: Encodable {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let keyMeta = try (self.reference.coder as! MetaEncoder).wrap(value)
        try reference.coder.stack.removeLastCodingKey()
        
        let valueMeta = try (self.reference.coder as! MetaEncoder).wrap(value)
        try reference.coder.stack.removeLastCodingKey()
        
        self.referencedMeta.add(key: keyMeta, value: valueMeta)
        
    }
    
    /**
     This method encodes a key or a value, depending on what was encoded last.
     
     Always call this method along with another call of it, one for a key, one for a value.
     You need to call this function for the key first and for the value second.
     Those two elements will be grouped to one key value pair.
     */
    public func encode<Element>(single element: Element) throws where Element: Encodable {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let meta = try (self.reference.coder as! MetaEncoder).wrap(element)
        
        try reference.coder.stack.removeLastCodingKey()
        
        self.referencedMeta.addSingle(meta: meta)
    }
    
    // MARK: - nested container
    
    public func nestedGeneralContainer<Key>(forKey key: Key) throws -> GeneralEncodingContainer where Key : Encodable {
        
        // the coding path needs to be extended, because wrap(key) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let keyMeta = try (self.reference.coder as! MetaEncoder).wrap(key)
        try reference.coder.stack.removeLastCodingKey()
        
        let nestedMeta = (self.reference.coder.translator as! MsgpackTranslator).generalContainerMeta()
        
        self.referencedMeta.add(key: keyMeta, value: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(GeneralCodingKey())
        defer { self.codingPath.removeLast() }
        
        return GeneralEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
    public func nestedContainer<NestedKey, Key>(keyedBy keyType: NestedKey.Type, forKey key: Key) throws -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey, Key: Encodable {
        
        // the coding path needs to be extended, because wrap(key) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let keyMeta = try (self.reference.coder as! MetaEncoder).wrap(key)
        try reference.coder.stack.removeLastCodingKey()
        
        let nestedMeta = self.reference.coder.translator.keyedContainerMeta()
        
        self.referencedMeta.add(key: keyMeta, value: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(GeneralCodingKey())
        defer { self.codingPath.removeLast() }
        
        return KeyedEncodingContainer(
            MetaKeyedEncodingContainer<NestedKey>(referencing: nestedReference, codingPath: self.codingPath)
        )
        
    }
    
    public func nestedUnkeyedContainer<Key>(forKey key: Key) throws -> UnkeyedEncodingContainer where Key: Encodable {
        
        // the coding path needs to be extended, because wrap(key) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let keyMeta = try (self.reference.coder as! MetaEncoder).wrap(key)
        try reference.coder.stack.removeLastCodingKey()
        
        let nestedMeta = self.reference.coder.translator.unkeyedContainerMeta()
        
        self.referencedMeta.add(key: keyMeta, value: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(GeneralCodingKey())
        defer { self.codingPath.removeLast() }
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
    // MARK: - super encoder
    
    /* I dont't quite understand the concept behind this function, but I think it isn't that important
    open func superEncoder() -> Encoder {
        return superEncoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    */
    
    public func superEncoder<Key>(forKey key: Key) throws -> Encoder where Key: Encodable {
        
        // need to wrap the key first
        // the coding path needs to be extended, because wrap(key) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let keyMeta = try (self.reference.coder as! MetaEncoder).wrap(key)
        try reference.coder.stack.removeLastCodingKey()
        
        let referenceToOwnMeta = GeneralContainerReference(coder: self.reference.coder, element: self.referencedMeta, at: keyMeta)
        
        return ReferencingMetaEncoder(referencing: referenceToOwnMeta)
        
    }
    
}
