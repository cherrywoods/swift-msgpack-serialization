//
//  Support for CompatibilityTests.swift
//  MsgpackSerializationTests iOS
//
//  Created by cherrywoods on 11.01.18.
//

import Foundation
import MetaSerialization

enum FruitContainer: Hashable, Codable {
    
    case apple(Apple)
    case pear(Pear)
    case banana(Banana)
    
    init(from decoder: Decoder) throws {
        if let apple = try? Apple(from: decoder) {
            self = .apple(apple)
            
        } else if let pear = try? Pear(from: decoder) {
            self = .pear(pear)
            
        } else if let banana = try? Banana(from: decoder) {
            self = .banana(banana)
            
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Could not decode fruit"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .apple(let apple):
            try apple.encode(to: encoder)
        case .pear(let pear):
            try pear.encode(to: encoder)
        case .banana(let banana):
            try banana.encode(to: encoder)
        }
    }
    
    var hashValue: Int {
        switch self {
        case .apple(let value):
            return value.hashValue
        case .pear(let value):
            return value.hashValue
        case .banana(let value):
            return value.hashValue
        }
    }
    
    static func ==(lhs: FruitContainer, rhs: FruitContainer) -> Bool {
        switch (lhs, rhs) {
        case (.apple(let lhv), .apple(let rhv)):
            return lhv == rhv
        case (.pear(let lhv), .pear(let rhv)):
            return lhv == rhv
        case (.banana(let lhv), .banana(let rhv)):
            return lhv == rhv
        default:
            return false
        }
    }
    
}

enum FruitArrayContainer: Codable, Equatable {
    
    case value(Array<FruitContainer>)
    
    init(from decoder: Decoder) throws {
        self = .value( try Array<FruitContainer>(from: decoder) )
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .value(let value):
            try value.encode(to: encoder)
        }
    }
    
    static func ==(lhs: FruitArrayContainer, rhs: FruitArrayContainer) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhv), .value(let rhv)):
            guard lhv.count == rhv.count else { return false }
            for i in 0..<lhv.count {
                if lhv[i] != rhv[i] {
                    return false
                }
            }
            return true
        }
    }
    
}

enum BananaAndStringDictionaryContainer: Codable, Equatable {
    
    case value(Dictionary<Banana, String>)
    
    init(from decoder: Decoder) throws {
        self = .value( try Dictionary<Banana, String>(from: decoder) )
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .value(let value):
            try (encoder as! MetaEncoder).encodeIntermediate(value)
        }
    }
    
    static func ==(lhs: BananaAndStringDictionaryContainer, rhs: BananaAndStringDictionaryContainer) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhv), .value(let rhv)):
            // if the tow dictionarys have diffrent lengths, they can not be equal
            guard lhv.count == rhv.count else { return false }
            // remove all elements, that are also contained in rhs -> if elements remain, thay are not equal
            return (lhv.filter { (arg: (key: Banana, value: String)) -> Bool in let (key, value) = arg; return rhv[key] != nil ? rhv[key]! != value : true }).isEmpty
        }
    }
    
}

enum DoubleAndStringDictionaryContainer: Codable, Equatable {
    
    case value(Dictionary<Double, String>)
    
    init(from decoder: Decoder) throws {
        self = .value( try Dictionary<Double, String>(from: decoder) )
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .value(let value):
            try (encoder as! MetaEncoder).encodeIntermediate(value)
        }
    }
    
    static func ==(lhs: DoubleAndStringDictionaryContainer, rhs: DoubleAndStringDictionaryContainer) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhv), .value(let rhv)):
            // if the tow dictionarys have diffrent lengths, they can not be equal
            guard lhv.count == rhv.count else { return false }
            // remove all elements, that are also contained in rhs -> if elements remain, thay are not equal
            return (lhv.filter { (arg: (key: Double, value: String)) -> Bool in let (key, value) = arg; return rhv[key] != nil ? rhv[key]! != value : true }).isEmpty
        }
    }
    
}

enum StringAndBananaDictionaryContainer: Codable, Equatable {
    
    case value(Dictionary<String, Banana>)
    
    init(from decoder: Decoder) throws {
        self = .value( try Dictionary<String, Banana>(from: decoder) )
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .value(let value):
            try (encoder as! MetaEncoder).encodeIntermediate(value)
        }
    }
    
    static func ==(lhs: StringAndBananaDictionaryContainer, rhs: StringAndBananaDictionaryContainer) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhv), .value(let rhv)):
            // if the tow dictionarys have diffrent lengths, they can not be equal
            guard lhv.count == rhv.count else { return false }
            // remove all elements, that are also contained in rhs -> if elements remain, thay are not equal
            return (lhv.filter { (arg: (key: String, value: Banana)) -> Bool in let (key, value) = arg; return rhv[key] != nil ? rhv[key]! != value : true }).isEmpty
        }
    }
    
}
