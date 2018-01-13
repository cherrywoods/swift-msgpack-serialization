//
//  CustomTestClasses2.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 11.01.18.
//

import Foundation

protocol Fruit: Hashable, Codable {
    var color: String { get set }
}

struct Apple: Fruit {
    
    var color: String
    var radius: Double
    
    init(color: String, radius: Double) {
        self.color = color
        self.radius = radius
    }
    
    var hashValue: Int {
        var hash = 7;
        hash = 17 &* hash &+ self.radius.hashValue
        hash = 17 &* hash &+ self.color.hashValue
        return hash;
    }
    
    static func ==(lhs: Apple, rhs: Apple) -> Bool {
        return lhs.color == rhs.color && lhs.radius == rhs.radius
    }
    
}

struct Pear: Fruit {
    
    var color: String
    var width: Double
    var height: Double
    
    init(color: String, height: Double, width: Double) {
        self.color = color
        self.height = height
        self.width = width
    }
    
    var hashValue: Int {
        var hash = 5;
        hash = 53 &* hash &+ self.height.hashValue
        hash = 53 &* hash &+ self.width.hashValue
        hash = 53 &* hash &+ self.color.hashValue
        return hash;
    }
    
    static func ==(lhs: Pear, rhs: Pear) -> Bool {
        return lhs.color == rhs.color && lhs.height == rhs.height && lhs.width == rhs.width
    }
    
}

class Banana: Fruit {
    
    var length: Double
    var color: String
    
    init( length: Double ) {
        self.color = "yellow"
        self.length = length
    }
    
    public func age() {
        switch color {
        case "yellow":
            self.color = "brown"
        case "brown":
            self.color = "dark brown"
        case "dark brown":
            self.color = "black"
        default:
            self.color = "still black"
        }
    }
    
    var hashValue: Int {
        var hash = 7;
        hash = 17 &* hash &+ self.length.hashValue
        hash = 17 &* hash &+ self.color.hashValue
        return hash;
    }
    
    static func ==(lhs: Banana, rhs: Banana) -> Bool {
        return lhs.color == rhs.color && lhs.length == rhs.length
    }
    
}

