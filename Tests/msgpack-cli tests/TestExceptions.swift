//
//  TestExceptions.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 21.02.18.
//
//  These tests are similar to the ExceptionTests from msgpack-cli
//  The expected msgpack values were partially generated by msgpack-tools
//  (https://github.com/ludocode/msgpack-tools)
//

import XCTest
@testable import MsgpackSerialization

class Exceptions: XCTestCase {

    func testInvalidMsgpack() {
        
        // test variants of invalid msgpack
        
        // empty data just isn't valid msgpack
        TestUtilites.testDecodeFailure(of: Data(), type: String.self)
        // byte array contains one byte less then expected
        TestUtilites.testDecodeFailure(of: [0xa3, 0x61, 0x62], type: String.self)
        // byte array contains one str less then expected
        TestUtilites.testDecodeFailure(of: [0x94, 0xa4, 0x6e, 0x61, 0x6d, 0x65, 0xa3, 0x61,0x67, 0x65, 0xad, 0x64, 0x61, 0x74, 0x65, 0x20, 0x6f, 0x66, 0x20, 0x62, 0x69, 0x72, 0x74, 0x68,], type: Array<String>.self)
        
        // test specific for .invalidMsgpack
        do {
            
            let _ = try TestUtilites.dataSerialization.decode(toType: String.self, from: Data(bytes: [0xa3, 0x61, 0x62]))
            XCTFail()
            
        } catch MsgpackError.invalidMsgpack {
            
            // this is fine
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    func testUnknownMsgpack() {
        
        // c1 is an unused header in msgpack
        TestUtilites.testDecodeFailure(of: [0xc1], type: Int.self)
        
        // test specific for .unknownMsgpack
        do {
            
            let _ = try TestUtilites.dataSerialization.decode(toType: Dictionary<String, Int>.self,
                                                              //                  this v header was changed
                                                              from: Data(bytes: [0x81, 0xc1, 0x61, 0x67, 0x65, 0x21] ))
            XCTFail()
            
        } catch MsgpackError.unknownMsgpack {
            
            // this is fine
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    func testOverlengthed() {
        /*
        let overlengthedData = Data(repeating: 1, count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedData)
        */
        /* Creating this string takes to long, so skip this test
        let overlengthedString = String(repeating: "o", count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedString)
         */
        
        let overlengthedArray = Array<Int8>(repeating: -1, count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedArray)
        
        // also don't test dictionary
        
    }
    
}
