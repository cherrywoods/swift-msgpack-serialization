//
//  TestFloatingPointEncoding.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 20.02.18.
//
//  This test isn't really related to the msgpack-cli tests.
//  It tests all floating point number formats.
//

import XCTest
@testable import MsgpackSerialization

class FloatingPointEncoding: XCTestCase {

    // test float32 format
    func testFloat32() {
        
        TestUtilites.testRoundTrip(of: Float(0.0), expected: [0xca, 0x00, 0x00, 0x00, 0x00])
        TestUtilites.testRoundTrip(of: Float(2.5), expected: [0xca, 0x40, 0x20, 0x00, 0x00])
        TestUtilites.testRoundTrip(of: Float(-3.4028235E38), expected: [0xca, 0xff, 0x7f, 0xff, 0xff])
        TestUtilites.testRoundTrip(of: Float.infinity, expected: [0xca, 0x7f, 0x80, 0x00, 0x00])
        TestUtilites.testRoundTrip(of: -Float.infinity, expected: [0xca, 0xff, 0x80, 0x00, 0x00])
        
        // test type coercion to Float, if Double value can be represented as float
        TestUtilites.testRoundTrip(of: Double(0.5), expected: [0xca, 0x3f, 0x00, 0x00, 0x00])
        // Double.infinity can also be represented as float
        TestUtilites.testRoundTrip(of: Double.infinity, expected: [0xca, 0x7f, 0x80, 0x00, 0x00])
        TestUtilites.testRoundTrip(of: -1*Double.infinity, expected: [0xca, 0xff, 0x80, 0x00, 0x00])
        
    }
    
    func testFloat64() {
        
        // these msgpack values were created by msgpack-tools (https://github.com/ludocode/msgpack-tools)
        
        TestUtilites.testRoundTrip(of: 4.94065645841246544176568792868E-324, expected: [0xcb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x01])
        TestUtilites.testRoundTrip(of: -2.24711643532021687194705837831E307, expected: [0xcb, 0xff, 0xc0, 0x00, 0x00, 0x02, 0x00, 0x00,0x00])
        TestUtilites.testRoundTrip(of: 7.92441800639598852668868351546E269, expected: [0xcb, 0x77, 0xf8, 0x00, 0x00, 0x02, 0x00, 0x00,0x00])
        
    }
    
}
