//
//  CustomTestClasses.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 21.12.17.
//

import Foundation

internal class Forest: Codable, Equatable {
    
    var location: String
    var trees: [Tree]
    
    init( trees: [Tree], location: String ) {
        self.trees = trees
        self.location = location
    }
    
    static func ==(lhs: Forest, rhs: Forest) -> Bool {
        
        return lhs.location == rhs.location && lhs.trees == rhs.trees
        
    }
    
}

internal class Tree: Codable, Equatable {
    
    var height: Double
    var width: Double
    var age: Int
    var kind: KindOfTree
    
    init( height: Double, width: Double, age: Int, kind: KindOfTree ) {
        self.height = height
        self.width = width
        self.age = age
        self.kind = kind
    }
    
    static func ==(lhs: Tree, rhs: Tree) -> Bool {
        
        return lhs.height == rhs.height && lhs.width == rhs.width && lhs.age == rhs.age && lhs.kind == rhs.kind
        
    }
    
}

internal enum KindOfTree: String, Codable {
    
    case oak = "OAK", spruce = "SPRUCE", lime = "LIME", fir = "FIR", other = "OTHER"
    
}
