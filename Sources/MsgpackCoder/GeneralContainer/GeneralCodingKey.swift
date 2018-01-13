//
//  GeneralCodingKey.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 11.01.18.
//

import Foundation

struct GeneralCodingKey: CodingKey {
    
    /// Will init with the string value "Some key-value pair"
    init() {
        self.init(stringValue: "Some key-value pair")
    }
    
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? = nil
    
    // Will always fail
    init?(intValue: Int) {
        return nil
    }
    
}
