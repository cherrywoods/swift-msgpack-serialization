//
//  BasicTests.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 17.12.17.
//

import XCTest
import MessagePack
@testable import MsgpackSerialization

class BasicTest: XCTestCase {
    
    private let dataPacker = Packer<Data>()
    private let messagePackValuePacker = Packer<MessagePackValue>()
    
    
    /**
     Encodes and decodes some ints, strings, floats, doubles and data
     */
    func testBasic() {
        
        let int = 0xC0FFEE
        let int8: Int8 = 42
        let uint16: UInt16 = 0xABCD
        let int32: Int32 = -40000
        let uint64: UInt64 = 0
        
        let string = "msgpack"
        
        let float: Float = 1.45574
        let double = 14456.5552236779897764
        
        // both should be serialized to msgpack binary
        let data = Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 143])
        let byteArray: [UInt8] = [ 0, 55, 23, 17 ]
        
        let ext = Door(isOpen: true)
        
        // encode and decode
        
        roundWaySerializeAndTest(int)
        roundWaySerializeAndTest(int8)
        roundWaySerializeAndTest(uint16)
        roundWaySerializeAndTest(int32)
        roundWaySerializeAndTest(uint64)
        roundWaySerializeAndTest(string)
        roundWaySerializeAndTest(float)
        roundWaySerializeAndTest(double)
        roundWaySerializeAndTest(data)
        roundWaySerializeAndTest(byteArray)
        roundWaySerializeAndTest(ext)
        
    }
    
    func testCollections() {
        
        // these two values are serialized as unkeyedContainers
        let array = [ "cherry", "banana", "peach" ]
        let set = Set(arrayLiteral: 3.5, 7.9, 9.9, 9.999, 9.9999999)
        
        // this dictionary is serialized to a keyedContainer by Dictionary
        let dictionary = [ 12 : "twelve", 13 : "thirteen", 1 : "one", 42 : "Answer to the Ultimate Question of Life, the Universe, and Everything" ]
        // these dictionarys are serialized to unkeyedContainers by Dictionary
        let dictionary2 = [ 2.5 : "a value", 44.7 : "a second value" ]
        
        let b1 = Banana(length: 3.0)
        let b2 = Banana(length: 3.0)
        let b3 = Banana(length: 3.0)
        
        b1.age(); b1.age(); b1.age();
        b2.age()
        
        let dictionary3 = BananaAndStringDictionaryContainer.value([ b1 : "a verry old banana",
                                                                     b2 : "a old banana",
                                                                     b3 : "a banana" ])
        
        roundWaySerializeAndTest(array)
        roundWaySerializeAndTest(set)
        
        roundWaySerializeAndTest(dictionary)
        roundWaySerializeAndTest(dictionary2)
        roundWaySerializeAndTest(dictionary3)
        
    }
    
    func testCustomObjects() {
        
        let tree1 = Tree(height: 10.32, width: 5.77, age: 59, kind: .fir)
        let tree2 = Tree(height: 7.84, width: 7.67, age: 112, kind: .oak)
        let tree3 = Tree(height: 14.7, width: 8.1, age: 87, kind: .spruce)
        let tree4 = Tree(height: 13.69, width: 4.914, age: 30, kind: .other)
        let tree5 = Tree(height: 12.85, width: 5.13, age: 30, kind: .other)
        
        let forest = Forest(trees: [tree1, tree2, tree3, tree4, tree5], location: "north-east")
        
        roundWaySerializeAndTest(forest)
        
    }
    
    private func roundWaySerializeAndTest<T>(_ value: T) where T: Codable&Equatable {
        
        // Test data serialization
        
        let serialized = try? dataPacker.encode(value)
        XCTAssertNotNil(serialized, "serializing value: \(value) of type \(T.self) failed")
        
        if serialized != nil {
            
            let deserialized = try? dataPacker.decode(toType: T.self, from: serialized! )
            XCTAssertNotNil(deserialized, "deserializing to type \(T.self) failed")
            
            if deserialized != nil {
                
                XCTAssertEqual(deserialized!, value)
                
            }
        }
        
        // test MessagePackValue serialization
        
        let serialized2 = try? messagePackValuePacker.encode(value)
        XCTAssertNotNil(serialized2, "serializing value: \(value) of type \(T.self) failed")
        
        if serialized2 != nil {
            
            let deserialized2 = try? messagePackValuePacker.decode(toType: T.self, from: serialized2! )
            XCTAssertNotNil(deserialized2, "deserializing to type \(T.self) failed")
            
            if deserialized2 != nil {
                
                XCTAssertEqual(deserialized2!, value)
                
            }
        }
        
    }
    
    private func roundWaySerializeAndTest<T>(_ value: [T]) where T: Codable&Equatable {
        
        // Test data serialization
        
        let serialized = try? dataPacker.encode(value)
        XCTAssertNotNil(serialized, "serializing value: \(value) of type \([T].self) failed")
        
        if serialized != nil {
            
            let deserialized = try? dataPacker.decode(toType: [T].self, from: serialized! )
            XCTAssertNotNil(deserialized, "deserializing to type \([T].self) failed")
            
            if deserialized != nil {
                
                XCTAssertEqual(deserialized!, value)
                
            }
        }
        
        // test MessagePackValue serialization
        
        let serialized2 = try? messagePackValuePacker.encode(value)
        XCTAssertNotNil(serialized2, "serializing value: \(value) of type \([T].self) failed")
        
        if serialized2 != nil {
            
            let deserialized2 = try? messagePackValuePacker.decode(toType: [T].self, from: serialized2! )
            XCTAssertNotNil(deserialized2, "deserializing to type \([T].self) failed")
            
            if deserialized2 != nil {
                
                XCTAssertEqual(deserialized2!, value)
                
            }
        }
        
    }
    
    private func roundWaySerializeAndTest<K, V>(_ value: [K:V]) where K: Codable, V:Codable&Equatable {
        
        // Test data serialization
        
        let serialized = try? dataPacker.encode(value)
        XCTAssertNotNil(serialized, "serializing value: \(value) of type \([K:V].self) failed")
        
        if serialized != nil {
            
            let deserialized = try? dataPacker.decode(toType: [K:V].self, from: serialized! )
            XCTAssertNotNil(deserialized, "deserializing to type \([K:V].self) failed")
            
            if deserialized != nil {
                
                XCTAssertEqual(deserialized!, value)
                
            }
        }
        
        // test MessagePackValue serialization
        
        let serialized2 = try? messagePackValuePacker.encode(value)
        XCTAssertNotNil(serialized2, "serializing value: \(value) of type \([K:V].self) failed")
        
        if serialized2 != nil {
            
            let deserialized2 = try? messagePackValuePacker.decode(toType: [K:V].self, from: serialized2! )
            XCTAssertNotNil(deserialized2, "deserializing to type \([K:V].self) failed")
            
            if deserialized2 != nil {
                
                XCTAssertEqual(deserialized2!, value)
                
            }
        }
        
    }
}
