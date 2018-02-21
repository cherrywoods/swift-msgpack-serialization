//
//  TestStringEncoding.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 20.02.18.
//
//  These tests are similar to the DirectConversionTests from msgpack-cli
//  The expected msgpack values were partially generated by msgpack-tools
//  (https://github.com/ludocode/msgpack-tools)
//

import XCTest
@testable import MsgpackSerialization

class StringEncoding: XCTestCase {

    func testFixStrFormat() {
        
        TestUtilites.testRoundTrip(of: "", expected: [0xa0])
        TestUtilites.testRoundTrip(of: "a", expected: [0xa1, 0x61])
        TestUtilites.testRoundTrip(of: "ab", expected: [0xa2, 0x61, 0x62])
        TestUtilites.testRoundTrip(of: "abc", expected: [0xa3, 0x61, 0x62, 0x63])
        // the following is equal to \ud9c9\udd31
        TestUtilites.testRoundTrip(of: "\u{82531}", expected: [0xa4, 0xf2, 0x82, 0x94, 0xb1])
        TestUtilites.testRoundTrip(of: "\u{30e1}\u{30c3}\u{30bb}\u{30fc}\u{30b8}\u{30d1}\u{30c3}\u{30af}", expected: [0xb8, 0xe3, 0x83, 0xa1, 0xe3, 0x83, 0x83, 0xe3,0x82, 0xbb, 0xe3, 0x83, 0xbc, 0xe3, 0x82, 0xb8, 0xe3, 0x83, 0x91, 0xe3, 0x83, 0x83, 0xe3, 0x82,0xaf])
        
    }
    
    func testStr8Format() {
        
        let a240Times = String(repeating: "a", count: 240)
        let expectedForA240Times = Data(bytes: [0xd9, 240]) + Data(repeating: 0x61, count: 240)
        TestUtilites.testRoundTrip(of: a240Times, expected: expectedForA240Times)
        
        // 🐶 == \u{1F436} == F0 9F 90 B6
        let twentyDogs = String(repeating: "🐶", count: 20)
        // one dog makes 4 utf8 chars, therefor 20 dogs make 80 chars
        let expectedForTwentyDogs = Data(bytes: [0xd9, 80, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6, 0xf0, 0x9f, 0x90, 0xb6])
        TestUtilites.testRoundTrip(of: twentyDogs, expected: expectedForTwentyDogs)
        
    }
    
    func testStr16Format() {
        
        // from now on just test for the right length of the msgpack data
        let tenThousandDucks = String(repeating: "🦆", count: 10_000)
        // the expected length is 3 (header + length) + 40_000 (because one duck converts to 4 utf-8 values)
        TestUtilites.testRoundTrip(of: tenThousandDucks, expectedLength: 40_003)
        
    }
    
    func testStr32Format() {
        
        // this test will take some time...
        // ok, we are not going to do one million (don't want to wait for ever...),
        // but just enough to get close to 2^16+2
        // therefor, we use 17.500 unicorns (but 17.500 unicorns are pretty cool to)
        let oneMillionUnicorns = String(repeating: "🦄", count: 17_500)
        // the expected length is 5 (header + length) + 70_000 (because one unicorn converts to 4 utf-8 values)
        TestUtilites.testRoundTrip(of: oneMillionUnicorns, expectedLength: 70_005)
        
    }
    
}