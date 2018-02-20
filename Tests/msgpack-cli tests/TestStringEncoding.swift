//
//  TestStringEncoding.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 20.02.18.
//
//  These tests are similar to the DirectConversionTests from msgpack-cli
//

import XCTest
@testable import MsgpackSerialization

class StringEncoding: XCTestCase {

    /*
    TestString( "" );
    TestString( "a" );
    TestString( "ab" );
    TestString( "abc" );
    TestString( "\ud9c9\udd31" );
    TestString( "\u30e1\u30c3\u30bb\u30fc\u30b8\u30d1\u30c3\u30af" );
    */

    func testBasicStrings() {
        
        TestUtilites.testRoundTrip(of: "", expected: [0xa0])
        TestUtilites.testRoundTrip(of: "a", expected: [0xa1, 0x61])
        
    }
    
}
