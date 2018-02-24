//
//  TestMapEncoding.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 22.02.18.
//
//  These tests are similar to Tests from msgpack-cli
//  The expected msgpack values were partially generated by msgpack-tools
//  (https://github.com/ludocode/msgpack-tools)
//

import XCTest
@testable import MsgpackSerialization

class MapEncoding: XCTestCase {
    
    func testFixMapFormat() {
        
        TestUtilites.testRoundTrip(of: DictionaryWrapper(["name": "frank"]),
                                   expected: [0x81, 0xa4, 0x6e, 0x61, 0x6d, 0x65, 0xa5, 0x66,0x72, 0x61, 0x6e, 0x6b])
        // the order the dictionary is encoded is a bit twisted (2, 3, 1 on my computer)
        // it is possible, that this this test fails due to this ordering
        TestUtilites.testRoundTrip(of: DictionaryWrapper([1: "one", 2: "two", 3: "three"]),
                                   expected: [0x83, 0x02, 0xa3, 0x74, 0x77, 0x6f, 0x03, 0xa5, 0x74, 0x68, 0x72, 0x65, 0x65, 0x01, 0xa3, 0x6f, 0x6e, 0x65])
        
    }
    
    func testMap16Format() {
        
        // from now on just test for the right length of the msgpack data
        
        // create map with 10_000 key value pairs
        var tenThousandElements = [Int: Int]()
        // use keys from 10_000 to 20_000 to get a fix key length
        for int in 10_000..<20_000 {
            tenThousandElements[int] = 0
        }
        // the expected length is 3 (header + length) + 30_000 (the key needs 2 bytes, plus header byte) + 10_000 (the value needs just one byte)
        TestUtilites.testRoundTrip(of: DictionaryWrapper(tenThousandElements), expectedLength: 40_003)
        
    }
    
    func testMap32Format() {
        
        // this test will also take some time
        
        // create map with 70_000 key value pairs
        var manyManyElements = [Int: Int]()
        // use keys from 70_000 to 140_000 to get a fix key length
        for int in 70_000..<140_000 {
            manyManyElements[int] = -4
        }
        // the expected length is 5 (header + length) + 350_000 (the key needs 4 bytes, plus header byte) + 70_000 (the value needs just one byte)
        TestUtilites.testRoundTrip(of: DictionaryWrapper(manyManyElements), expectedLength: 420_005)
        
    }
    
    fileprivate struct DictionaryWrapper<K, V>: Codable, Equatable where K: Hashable, V: Equatable {
        
        let value: [K:V]
        
        init(_ value: [K:V]) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            self.value = try decoder.singleValueContainer().decode([K:V].self)
        }
        
        func encode(to encoder: Encoder) throws {
            var sVC = encoder.singleValueContainer()
            try sVC.encode(value)
        }
        
        static func ==(lhs: MapEncoding.DictionaryWrapper<K, V>, rhs: MapEncoding.DictionaryWrapper<K, V>) -> Bool {
            return lhs.value == rhs.value
        }
        
    }
    
}