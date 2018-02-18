//
//  NumberalMeta.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 12.11.17.
//

import Foundation
import MetaSerialization

/**
 A meta for storing int values.
 Enables type casting to all types of ints.
 Only used during decoding.
 */
internal class IntFormatMeta<BI>: SimpleGenericMeta<BI> where BI: BinaryInteger {
    
    /**
     Cast this value to another kind of BinaryInteger.
     - Parameter allowLoosyConversion: specify, whether this method should throw an error, if the contained value could not be casted or whether it should convert it anyway using init(clamping:).
     - Throws: if allowLoosyConversion was true, this method will throw MsgpackError.numberCouldNotBeConvertedWithoutLoss, if a number could not be converted without loss.
     */
    func castTo<OtherBI>(allowLoosyConversion: Bool) throws -> OtherBI? where OtherBI: BinaryInteger {
        
        guard let value = self.value else {
            return nil
        }
        
        if allowLoosyConversion {
            
            // use init(clamping: )
            return OtherBI(clamping: value)
            
        } else { // do not clamp
            
            // use init(exactly: )
            if let exactValue = OtherBI(exactly: value) {
                return exactValue
            } else {
                // throw error, if the value could not be converted
                throw MsgpackError.numberCouldNotBeConvertedWithoutLoss(number: value)
            }
            
            
        }
        
    }
    
}
