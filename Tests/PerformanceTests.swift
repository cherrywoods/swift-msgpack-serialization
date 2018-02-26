//  PerformanceTests.swift
//  MsgpackSerializationTests iOS
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import XCTest
import MessagePack
@testable import MsgpackSerialization

class PerformanceTests: XCTestCase {

    let dataPacker = Packer<Data>()
    let mPVPacker = Packer<MessagePackValue>()
    
    func testPerformanceSMPImpl() {
        
        // test verry large strings
        let oneMillionUnicorns = String(repeating: "🦄", count: 17_500)
        
        self.measure {
            
            let encoded = try! dataPacker.encode(oneMillionUnicorns)
            let _ = try! dataPacker.decode(toType: String.self, from: encoded)
            
        }
        
    }
    
    func testPerformanceMPSImpl() {
        
        let oneMillionUnicorns = String(repeating: "🦄", count: 17_500)
        
        self.measure {
            
            let encoded = try! mPVPacker.encode(oneMillionUnicorns)
            let _ = try! mPVPacker.decode(toType: String.self, from: encoded)
            
        }
        
    }
    
}
