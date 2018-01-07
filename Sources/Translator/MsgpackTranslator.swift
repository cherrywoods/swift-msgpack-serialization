//
//  MsgpackTranslator.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 28.10.17.
//

import Foundation
import MetaSerialization

internal class MsgpackTranslator: Translator {
    
    // TODO: it seems to me as if there were some special mechanisms to handle
    // overlengther data in msgpack-java. They should be mirrored
    
    // TODO: support streams
    
    /*
     ideas:
     Extend Data to take Binary Integer or UInt32 instead of Data.Index (Int) for some methods (e.g. subdata)
     
     Rewrite all methods taking Data.Index to take some Binary Integer, delegating the subdata, etc. methods to
     another method, with architecture specific implmentations, throwing an error, if decoding is impossible.
     */
    
    // MARK: - Encoding and Decoding Options
    
    /**
     Provide additional information for the translation process.
     */
    internal var optionSet: Configuration = Configuration()
    
    internal init(with options: Configuration) {
        self.optionSet = options
    }
    
    // see MsgpackTranslator + Meta Stage for implementations of wrap and unwrap
    
    // see MsgpackTranslator + De/Encoding Stage for implementations of encode and decode
    
}
