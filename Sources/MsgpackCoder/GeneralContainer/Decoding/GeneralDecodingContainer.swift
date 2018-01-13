//
//  GeneralDecodingContainer.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 13.01.18.
//

import Foundation
import MetaSerialization

/**
 A container that makes directly decoding arbitrary keyed collections possible.
 
 The container works similar to a UnkeyedDecodingContainer.
 You can decode key value pairs one by another.
 Most methods decode eighter a key or a value, depending on the order they are called.
 See decode(singleType: ) for more information. The order applies across all fuctions,
 so if you call nestedUnkeyedContainer() for a key position, the next value superDecoder() refers to is a value.
 */
public class GeneralDecodingContainer {
    
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
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    // MARK: - container methods
    
    /// the number of key value pairs in this container
    open var count: Int? {
        return referencedMeta.map.count
    }
    
    /// returns whether no further key value pair can be decoded
    open var isAtEnd: Bool {
        return self.currentIndex == self.count
    }
    
    // this index is counted per element, not per key value pair
    private var currentIndex: Int = 0
    
    // MARK: - decoding
    
    /**
     Decodes a key and checks whether the next value is nil.
     
     If the next value is nil, the next call of decode(singleType: ) will return a key.
     If the next value isn't nil, the next call of decode(singleType: ) is a Value.
     Therefor if you use this method and the next value isn't nil, call decode(singleType: ) before calling any other function of this container.
     */
    open func decodeNil<Key>(forKey keyType: Key.Type) throws -> (Key, Bool) where Key: Decodable {
        
        let key = try decode(singleType: Key.self)
        let isNil = try decodeNil()
        
        return (key, isNil)
        
    }
    
    open func decode<Key,Value>(key keyType: Key.Type, value valueType: Value.Type) throws -> (Key, Value) where Key: Decodable, Value: Decodable {
        
        let key = try decode(singleType: Key.self)
        let value = try decode(singleType: Value.self)
        
        return (key, value)
        
    }
    
    /**
     This method decodes a key or a value, depending on what was decoded last.
     
     Always call this method along with another call of it, one for a key, one for a value.
     You need to call this function for the key first and for the value second.
     */
    public func decode<Element>(singleType type: Element.Type) throws -> Element where Element: Decodable {
        
        // first check whether the container still has an element
        guard let subMeta = referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // the coding path needs to be extended, because unwrap(meta) may throw an error
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        let value: Element = try (self.reference.coder as! MetaDecoder).unwrap(subMeta)
        
        try reference.coder.stack.removeLastCodingKey()
        
        // now we decoded a value with success,
        // therefor we can increment currentIndex
        self.currentIndex += 1
        
        return value
        
    }
    
    /**
     This method works as decode(single: )
     */
    open func decodeNil() throws -> Bool {
        
        // first check whether the container still has an element
        guard let subMeta = referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(Any?.self, context)
        }
        
        let isNil = subMeta is NilMetaProtocol
        // increment only, if value is nil
        if isNil { self.currentIndex += 1 }
        return isNil
        
    }
    
    // MARK: - nested container
    
    /**
     This function works as decode(single: )
     */
    public func nestedGeneralContainer() throws -> GeneralDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(GeneralEncodingContainer.self, context)
        }
        
        // check, wheter subMeta is a GeneralEncodingContainer
        guard let containerSubMeta = subMeta as? MapMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(GeneralEncodingContainer.self, context)
        }
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: containerSubMeta)
        
        return  GeneralDecodingContainer(referencing: nestedReference)
        
    }
    
    /**
     This function works as decode(single: )
     */
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        // check whether the container still has an element first
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // check, wheter subMeta is a KeyedContainerMeta
        guard let keyedSubMeta = subMeta as? KeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<NestedKey>.self, context)
        }
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: keyedSubMeta)
        
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<NestedKey>(referencing: nestedReference)
        )
        
    }
    
    /**
     This function works as decode(single: )
     */
    public func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "GeneralContainer is at end.")
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let unkeyedSubMeta = subMeta as? UnkeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: unkeyedSubMeta)
        
        return  MetaUnkeyedDecodingContainer(referencing: nestedReference)
        
    }
    
    // MARK: - super encoder
    
    /**
     This function also works as decode(single: )
     */
    open func superDecoder() throws -> Decoder {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        try reference.coder.stack.append(codingKey: GeneralCodingKey())
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(Decoder.self, context)
        }
        
        let referenceToOwnMeta = UnkeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, index: currentIndex)
        let decoder = ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
        self.currentIndex += 1
        return decoder
        
    }
    
}
