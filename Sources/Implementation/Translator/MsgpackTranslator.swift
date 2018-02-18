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
