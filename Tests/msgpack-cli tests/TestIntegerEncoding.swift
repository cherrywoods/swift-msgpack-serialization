//
//  TestIntegerEncoding.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 19.02.18.
//

import XCTest
@testable import MsgpackSerialization

class IntegerEncoding: XCTestCase {
    
    // test this formats:
    // positive and negative fixnum
    func testSingleByteInts() {
        
        TestUtilites.testRoundTrip(of: 0, expected: [0] )
        TestUtilites.testRoundTrip(of: 127, expected: [0x7f])
        TestUtilites.testRoundTrip(of: -1, expected: [0xff])
        TestUtilites.testRoundTrip(of: -7, expected: [0xe1])
        
    }
    
}
