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
        
        // test specificly for .invalidMsgpack
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
        
        // test specificly for .unknownMsgpack
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
        
        let overlengthedData = Data(repeating: 1, count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedData)
 
        /* Creating this string takes to long, so skip this test
        let overlengthedString = String(repeating: "o", count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedString)
         */
        
        /* Encoding this array also takes to long
        let overlengthedArray = Array<Int8>(repeating: -1, count: 4_294_967_297)
        TestUtilites.testEncodeFailure(of: overlengthedArray)
         */
        
        // also don't test dictionary
        
        // test specificly for .valueExceededSupportedLength
        do {
            
            let _ = try MsgpackExtensionValue(type: 12, data: overlengthedData)
            XCTFail()
            
        } catch MsgpackError.valueExceededSupportedLength {
            
            // this is fine
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    func testInvalidStringData() {
        
        do {
            
            let _ = try TestUtilites.dataSerialization.decode(toType: String.self,
                                                              // third byte is invalid utf8
                                                              from: Data(bytes: [0xa3, 0x61, 0x80, 0x63]))
            XCTFail()
            
        } catch MsgpackError.invalidStringData(rawData: let data) {
            
            // check that the returned invalid data is the encoded string data
            if data != Data(bytes: [0x61, 0x80, 0x63]) {
                XCTFail("Encoded data did not match thrown data")
            } else {
                // this is fine
            }
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    func testNumberCouldNotBeConvertedWithoutLoss() {
        
        let uint16: [UInt8] = [0xcd, 0x01, 0x00]
        let double: [UInt8] = [0xcb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x01]
        
        // test whether disabeling throwing works
        
        let loosySerialization = Packer<Data>(with: Configuration(allowLoosyNumberConversion: true, allowLoosyFloatingPointNumberConversion: true))
        
        TestUtilites.testDecoding(of: uint16, type: Int8.self, using: loosySerialization)
        TestUtilites.testDecoding(of: double, type: Float.self, using: loosySerialization)
        
        // now test for the errors
        
        do {
            
            let _ = try TestUtilites.dataSerialization.decode(toType: Int8.self, from: Data(bytes: uint16))
            XCTFail()
            
        } catch MsgpackError.numberCouldNotBeConvertedWithoutLoss(number: let number) {
            
            // check that the returned number is the right double
            if !(number is UInt16) || (number as! UInt16) != 256 {
                XCTFail("Encoded data did not match thrown data")
            } else {
                // this is fine
            }
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
        // the same for double
        
        do {
            
            let _ = try TestUtilites.dataSerialization.decode(toType: Float.self, from: Data(bytes: double))
            XCTFail()
            
        } catch MsgpackError.numberCouldNotBeConvertedWithoutLoss(number: let number) {
            
            // check that the returned number is the right double
            if !(number is Double) || (number as! Double) != 4.94065645841246544176568792868E-324 {
                XCTFail("Encoded data did not match thrown data")
            } else {
                // this is fine
            }
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    func testUnconvertibleDate() {
        
        let date1 = Date(timeIntervalSince1970: -62135769600.0)
        
        do {
            
            let _ = try TestUtilites.dataSerialization.encode(date1)
            XCTFail()
            
        } catch MsgpackError.dateUnconvertibleToTimestamp {
            
            // this is fine
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail()
        }
        
    }
    
    // FIXME: uncomment with next swift release, or 4.1 beta
    /*
    func testUnconvertibleTimestamp() {
        
        let uncoveredTimestamp: [UInt8] =
        //            12    -1  ----- nano second ----  ------------------ seconds -------------------
            [ 0xc7, 0x0c, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07 ]
        
        do {
            
            // TODO: write test for Int64 to double conversion in general
            // it seems not to work
            let _ = try TestUtilites.dataSerialization.decode(toType: Date.self, from: Data(bytes: uncoveredTimestamp))
            XCTFail()
            
        } catch MsgpackError.timestampUnconvertibleToDate {
            
            // this is fine
            
        } catch {
            // all other errors shouldn't be thrown
            XCTFail("\(error)")
        }
        
    }
    */
    
}
