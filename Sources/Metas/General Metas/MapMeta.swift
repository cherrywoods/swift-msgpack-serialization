//
//  MapMeta.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 09.12.17.
//

import Foundation
import MetaSerialization

/**
 A Meta to handle any kind of msgpack map value.
 
 This Meta also implements KeyedContainer behaviors,
 because keyed containers are translated to maps
 of strings and other things.
 
 The main purpose of this class is to fool dictionary.
 This class should (especially on the decoding side) mimic
 the container structure Dictionary creates of encoding.
 Since this structure is uncomon and not cross language compatibel
 we recreate it at this stage.
 
 Dictionary will encode more complex dictionarys
 (e.g. with custom classes as keys) as unkeyed container.
 Therefor a Map can also be seen as UnkeyedContainerMeta.
 */
internal class MapMeta: KeyedContainerMeta, UnkeyedContainerMeta {
    
    /*
     The key-value-pairs are stored as array,
     but additionaly there exists a dictionary
     that matches possible string values of the key metas
     to the correspoding possition, so that look-up
     for a string coding key is performed in amortized constant time
     */
    
    /*
     This Meta is used on encoding and decoding.
     
     On encoding this meta is used as regular keyed encoding container
     and as container for Dictionarys with arbitrary keys or values
     
     On decoding this meta is used for any map msgpack value.
     It might then be used as keyed container
     or as unkeyed container for some Dictionarys
     */
    
    // MARK: general Map functionality
    
    /// a container for the special needs of this class with constant time string-key lookup
    private class Storage {
        
        /// a placeholder to use in keyValuePairs
        struct Placeholder: Meta {
            mutating func set(value: Any) throws {  }
            func get() -> Any? { return nil }
        }
        
        /// the values of this map meta as array of key-value pairs
        private(set) var keyValuePairs: [(Meta, Meta)] = []
        
        /// stores the indices for certain string values of meta keys
        private var stringKeyIndices: [String:Int] = [:]
        
        func append(key: Meta, value: Meta) {
        
            // add an entry for the key to stringKeyIndices, if it is string convertible
            if let stringKey = asStringKey(key: key) {
                
                // .count will be the new index of the key-value pair
                stringKeyIndices[ stringKey ] = keyValuePairs.count
                
            }
            
            // append key-value-pair
            keyValuePairs.append( (key, value) )
            
        }
        
        func replaceLast(key: Meta, value: Meta) {
            
            self.keyValuePairs.removeLast()
            self.append(key: key, value: value)
            
        }
        
        // converts a key meta to a string key if needed
        private func asStringKey(key: Meta) -> String? {
            
            // Dictionary converts only Strings and Ints to coding keys.
            
            if key is SimpleGenericMeta<String> {
                return (key as! SimpleGenericMeta<String>).value
                
            } else if key is StringMeta {
                return (key as! StringMeta).value
                
            } else if key is SimpleGenericMeta<Int> {
                return (key as! SimpleGenericMeta<Int>).value?.description
                
            } else if key is IntFormatMeta<Int8> {
                return (key as! SimpleGenericMeta<Int8>).value?.description
            } else if key is IntFormatMeta<UInt8> {
                return (key as! SimpleGenericMeta<UInt8>).value?.description
            } else if key is IntFormatMeta<Int16> {
                return (key as! SimpleGenericMeta<Int16>).value?.description
            } else if key is IntFormatMeta<UInt16> {
                return (key as! SimpleGenericMeta<UInt16>).value?.description
            } else if key is IntFormatMeta<Int32> {
                return (key as! SimpleGenericMeta<Int32>).value?.description
            } else if key is IntFormatMeta<UInt32> {
                return (key as! SimpleGenericMeta<UInt32>).value?.description
            } else if key is IntFormatMeta<Int64> {
                return (key as! SimpleGenericMeta<Int64>).value?.description
            } else if key is IntFormatMeta<UInt64> {
                return (key as! SimpleGenericMeta<UInt64>).value?.description
                
            } else {
                return nil
            }
            
        }
        
        subscript(stringKey: String) -> Meta? {
            
            get {
                
                // find string value of codingKey in values (if it exists)
                if let index = stringKeyIndices[ stringKey ] {
                    
                    return keyValuePairs[index].1
                    
                } else {
                    
                    // if there's no entry, there's no meta contained
                    return nil
                    
                }
                
            }
            
            set (newValue) {
                
                // fill the place of the key in keyValuePairs
                // construct the key-value-pair to set or append for the key
                let keyPlaceholderMeta = StringMeta(value: stringKey) as Meta
                
                // lookup key; insert, if key existing / append if not existing
                if let index = stringKeyIndices[ stringKey ] {
                    
                    // if newValue is nil, we should remove the pair at the given key
                    if newValue == nil {
                        
                        keyValuePairs.remove(at: index)
                        
                    } else {
                        
                        // insert
                        keyValuePairs[index] = (keyPlaceholderMeta, newValue!)
                        
                    }
                    
                } else {
                    
                    // only append, if newValue is not nil
                    if newValue != nil {
                        
                        // append and add new key mapping
                        stringKeyIndices[stringKey] = keyValuePairs.count
                        keyValuePairs.append( (keyPlaceholderMeta, newValue!) )
                        
                    }
                    
                }
                
            }
            
        }
        
        var allStringKeys: [String] {
            return stringKeyIndices.keys.map { return $0 }
        }
        
        func contains(stringKey: String) -> Bool {
            return stringKeyIndices[stringKey] != nil
        }
        
    }
    
    /// stores all key-value-pairs and enables lookup for string-keys
    private var storage: Storage = Storage()
    
    /**
     Puts the given key-value pair into this map.
     - Parameter key: The key Meta
     - Parameter value: The value Meta
     - Parameter at: The position, at which this key value pair was contained in the maps msgpack data
     */
    func add(key: Meta, value: Meta) {
        
        storage.append(key: key, value: value)
        
    }
    
    var map: [(Meta, Meta)] {
        return storage.keyValuePairs
    }
    
    // this function exists as support for GeneralEncodingContainer
    func addSingle(meta: Meta) {
        
        // this function should always be called in groups of two
        
        // to determine whether the next element that should be inserted is a key
        // check whether storage is empty
        // or if the last key-value-pairs value is not a Storage.Placeholder
        // if so append key and a Placeholder
        
        // if the last value is a Placeholder, insert a value
        
        if self.storage.keyValuePairs.isEmpty ? true : !(self.storage.keyValuePairs.last!.1 is Storage.Placeholder) {
            
            // add key and placeholder
            self.storage.append(key: meta, value: Storage.Placeholder())
            
        } else {
            
            // insert value for placeholder
            let (key, _) = storage.keyValuePairs.last!
            self.storage.replaceLast(key: key, value: meta)
            
        }
        
    }
    
    /*
     The following two behaviors are just available in certain cases:
     - KeyedContainer: all keys are strings
     - UnkeyedContainer: all keys are numeric indizes
     If this condition is not satisfied, the key-value-pairs that do not satisfy the conditions are ignored.
     
     Note that this two behaviors do not intersect, if MapMeta is used as Meta for Dictionarys,
     because Dictionary will only expect a unkeyed structure, if the keys aren't strings
     */
    
    // MARK: KeyedContainerMeta functionality
    
    subscript(codingKey: CodingKey) -> Meta? {
        
        get {
            
            return storage[ codingKey.stringValue ]
            
        }
        
        set (newValue) {
            
            storage[ codingKey.stringValue ] = newValue
            
        }
        
    }
    
    func allKeys<CK>() -> [CK] where CK: CodingKey {
        
        // just return the string values
        // (actually, if a map is really a KeyedContainer
        // all keys should be strings, but checking that is hard)
        
        return storage.allStringKeys.flatMap { str in return CK(stringValue: str) }
        
    }
    
    func contains(key codingKey: CodingKey) -> Bool {
        
        return storage.contains(stringKey: codingKey.stringValue)
        
    }
    
    // MARK: UnkeyedContainerMeta functionality
    
    var count: Int? {
        
        // if seen as a unkeyed container, keys and values are separate
        return storage.keyValuePairs.count * 2
    }
    
    func get(at index: Int) -> Meta? {
        
        let (index, keyOrValue) = indices(for: index)
        
        // get element at the key (primary) index
        guard storage.keyValuePairs.count > index else {
            return nil // if index isn't contained, return nil
        }
        
        switch keyOrValue {
        case true: // this means key
            return storage.keyValuePairs[index].0
        case false: // this means value
            return storage.keyValuePairs[index].1
        }
        
    }
    
    private func indices(for index: Int) -> (Int, Bool) {
        
        // primaryIndex is the index in values
        // secondaryIndex determines whether to access key or value
        let (primaryIndex, secondaryIndex) = index.quotientAndRemainder(dividingBy: 2)
        
        // 0's (odd positions) are keys, 1's are values
        return (primaryIndex, secondaryIndex == 0)
        
    }
    
    // note that MapMeta is not build to be available as a UnkeyedMeta at encoding time
    
    /**
     This function will produce a crash and nothing more.
     */
    func insert(element: Meta, at index: Int) {
        
        preconditionFailure("insert is not usable on MapMeta")
        
    }
    
    func append(element: Meta) {
        
        preconditionFailure("append is not usable on MapMeta")
        
    }
    
    // MARK: get and set from Meta
    
    // the type we expect here is [(Meta, Meta)]
    
    func set(value: Any) throws {
        
        guard let array = value as? [(Meta, Meta)] else {
            preconditionFailure()
        }
        
        for (key, value) in array {
            storage.append(key: key, value: value)
        }
        
    }
    
    func get() -> Any? {
        
        return map
        
    }
    
}
