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
        
        do {
            
            let (encoded, decoded) = try testRoundTrip(of: value)
            
            if expected != nil {
                
                XCTAssert(expected! == encoded, "Produced ( \(convertToHexString(data: encoded)) ) not identical to expected ( \(convertToHexString(data: expected!)) ).")
                
            }
            
            XCTAssert(decoded == value, "\(type(of:value)) did not round-trip to an equal value. Expected: \(value), actual: \(decoded)")
            
        } catch {
            XCTFail("Failed to encode or decode \(T.self): \(error)")
        }
        
    }
    
    static func testRoundTrip<T>(of value: T, expected: [UInt8]) where T: Codable, T:Equatable {
        
        testRoundTrip(of: value, expected: Data(bytes: expected))
        
    }
    
    static func testRoundTrip<T>(of value: T, expectedLength: Int) where T: Codable, T: Equatable {
        
        do {
            
            let (encoded, decoded) = try testRoundTrip(of: value)
            
            XCTAssert(expectedLength == encoded.count, "Produced ( \(convertToHexString(data: encoded)) ) did not match the expected length of \(expectedLength) ).")
            
            XCTAssert(decoded == value, "\(type(of:value)) did not round-trip to an equal value. Expected: \(value), actual: \(decoded)")
            
        } catch {
            XCTFail("Failed to encode or decode \(T.self): \(error)")
        }
        
    }
    
    // encodes and decodes T and returns the encoded data and the decoded value then
    fileprivate static func testRoundTrip<T>(of value: T) throws -> (Data, T) where T: Codable {
        
        let encoded = try dataSerialization.encode(value)
        let decoded = try dataSerialization.decode(toType: T.self, from: encoded)
        
        return (encoded, decoded)
        
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
