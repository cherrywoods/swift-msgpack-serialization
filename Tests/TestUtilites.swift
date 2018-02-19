//
//  TestUtilites.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 19.02.18.
//

import XCTest
@testable import MsgpackSerialization

enum TestUtilites {
    
    static let dataSerialization = Packer<Data>()
    
    static func testRoundTrip<T>(of value: T, expected: Data? = nil) where T : Codable, T : Equatable {
        
        var payload: Data! = nil
        do {
            payload = try dataSerialization.encode(value)
        } catch {
            XCTFail("Failed to encode \(T.self): \(error)")
        }
        
        if expected != nil {
            
            XCTAssert(expected! == payload!, "Produced ( \(convertToHexString(data: payload!)) ) not identical to expected ( \(convertToHexString(data: expected!)) ).")
        }
        
        do {
            let decoded = try dataSerialization.decode(toType: T.self, from: payload)
            XCTAssert(decoded == value, "\(type(of:value)) did not round-trip to an equal value.")
        } catch {
            XCTFail("Failed to decode \(type(of:value)): \(error)")
        }
        
    }
    
    static func testRoundTrip<T>(of value: T, expected: [UInt8]) where T: Codable, T:Equatable {
        
        testRoundTrip(of: value, expected: Data(bytes: expected))
        
    }
    
    static func printForJava<T>(data: Data, type: T.Type) {
        
        print("Encoding type: \(T.self)")
        var string = "{ "
        for byte in data {
            string += "\(Int8(bitPattern: byte)), "
        }
        string += "};"
        print("{ " + convertToString(data: data) + "};")
        
    }
    
    static func convertToString(data: Data) -> String {
        
        var string = ""
        for byte in data {
            string += "\(Int8(bitPattern: byte)), "
        }
        return string
        
    }
    
    
    static func convertToHexString(data: Data) -> String {
        
        var string = ""
        for byte in data {
            string += "\(String(byte, radix: 16, uppercase: false)), "
        }
        return string
        
    }
    
}
