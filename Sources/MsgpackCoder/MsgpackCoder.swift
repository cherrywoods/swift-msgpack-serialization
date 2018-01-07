//
//  MsgpackCoder.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 22.12.17.
//

import Foundation
import MetaSerialization

// this classes just exist,
// so one can set the configuration of an translator at encoding or decoding time

/// the encoder implementation used by MsgpackSerialization
public class MsgpackEncoder: MetaEncoder {
    
    public var configuration: Configuration {
        get {
            return (translator as! MsgpackTranslator).optionSet
        }
        set {
            (translator as! MsgpackTranslator).optionSet = newValue
        }
    }
    
    internal init(with options: Configuration = Configuration())  {
        super.init(translator: MsgpackTranslator(with: options))
    }
    
}

/// the encoder implementation used by MsgpackSerialization
public class MsgpackDecoder: MetaDecoder {
    
    public var configuration: Configuration {
        get {
            return (translator as! MsgpackTranslator).optionSet
        }
        
        set {
            (translator as! MsgpackTranslator).optionSet = newValue
        }
    }
    
    internal convenience init<Raw>(with options: Configuration = Configuration(), raw: Raw) throws {
        try self.init(translator: MsgpackTranslator(with: options), raw: raw)
    }
    
}
