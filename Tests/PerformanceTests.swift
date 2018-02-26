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

    // SMS -> SwiftMspackSerialization (this implementation)
    // MPS -> MessagePack.swift
    
    let dataPacker = Packer<Data>()
    let mPVPacker = Packer<MessagePackValue>()
    
    func testPerformanceSMSImplString() {
        
        // test verry large strings
        let someUnicorns = String(repeating: "🦄", count: 500)
        
        self.measure {
            
            let encoded = try! dataPacker.encode(someUnicorns)
            let _ = try! dataPacker.decode(toType: String.self, from: encoded)
            
        }
        
    }
    
    func testPerformanceMPSImplString() {
        
        let someUnicorns = String(repeating: "🦄", count: 500)
        
        self.measure {
            
            let encoded = try! mPVPacker.encode(someUnicorns)
            let _ = try! mPVPacker.decode(toType: String.self, from: encoded)
            
        }
        
    }
    
    func testPerformanceSMSImplDeplyNested() {
        
        let nested = createNest(depth: 200)!
        
        self.measure {
            
            let encoded = try! dataPacker.encode(nested)
            let _ = try! dataPacker.decode(toType: Nest.self, from: encoded)
            
        }
        
    }
    
    func testPerformanceMPSImplDeplyNested() {
        
        let nested = createNest(depth: 200)!
        
        self.measure {
            
            let encoded = try! mPVPacker.encode(nested)
            let _ = try! mPVPacker.decode(toType: Nest.self, from: encoded)
            
        }
        
    }
    
    fileprivate class Nest: Codable {
        
        let nested: Nest?
        
        init(nested: Nest?) {
            self.nested = nested
        }
        
    }
    
    fileprivate func createNest(depth: Int) -> Nest? {
        
        if depth == 0 { return nil }
        else {
            
            return Nest(nested: createNest(depth: depth - 1) )
            
        }
        
    }
    
}
