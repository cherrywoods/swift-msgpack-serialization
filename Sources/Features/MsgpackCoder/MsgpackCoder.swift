//
//  MsgpackCoder.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 22.12.17.
//

import Foundation
import MetaSerialization

// make Configuration settable in encode(to: )
// and init(from: )
// plus provide generalContainer

/// the encoder implementation used by MsgpackSerialization
public class MsgpackEncoder: MetaEncoder {
    
    /// use this to set a configuration during encoding
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
    
    /// Request a general encoding container to encode arbitrary keyed collections.
    public func generalContainer() -> GeneralEncodingContainer {
        
        // if there's no container at the current codingPath, let translator create a new one and append it
        // if there is one and it is a MapMeta, its allright
        // otherwise crash the program
        do {
            try stack.push(meta: (translator as! MsgpackTranslator).generalContainerMeta() )
        } catch /*StackError.statusMismatch .push trows no other errors*/ {
            
            // check wether the last meta is a MapMeta
            guard stack.last is MapMeta else {
                preconditionFailure("Requested a second container at the same coding path: \(codingPath)")
            }
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return GeneralEncodingContainer(referencing: referencing, codingPath: self.codingPath)
        
    }
    
}

/// the encoder implementation used by MsgpackSerialization
public class MsgpackDecoder: MetaDecoder {
    
    /// use this to set a configuration during decoding
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
    
    /// Request a general decoding container to decode arbitrary keyed collections.
    public func generalContainer() throws -> GeneralDecodingContainer {
        
        guard self.stack.last is MapMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type does not match with expected type.")
            throw DecodingError.typeMismatch(GeneralDecodingContainer.self, context)
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return GeneralDecodingContainer(referencing: referencing)
        
    }
    
}
