//
//  ExtensionTestClasses.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 21.12.17.
//

import Foundation
@testable import MsgpackSerialization

internal class Door: MsgpackExtension, Equatable {
    
    private(set) internal var isOpen: Bool
    
    func open() {
        isOpen = true
    }
    
    func close() {
        isOpen = false
    }
    
    init(isOpen: Bool) {
        self.isOpen = isOpen
    }
    
    var extensionTypeCode: Int8 = 42
    
    // Door stores data as a single byte with value 7, if Door is open
    
    required init(from data: Data) throws {
        guard let first = data.first else {
            throw MsgpackError.invalidMsgpack
        }
        self.isOpen = first == 7
    }
    
    func encodeSelf() throws -> Data {
        
        return Data(bytes: [ isOpen ? 7 : 0 ])
        
    }
    
    // this is ofcourse pretty senceless
    static func ==(lhs: Door, rhs: Door) -> Bool {
        return lhs.isOpen == rhs.isOpen
    }
}
