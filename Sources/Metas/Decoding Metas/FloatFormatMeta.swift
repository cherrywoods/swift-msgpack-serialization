//
//  FloatFormatMeta.swift
//  swift-msgpack-serialization
//
//  Created by cherrywoods on 13.11.17.
//

import Foundation
import MetaSerialization

/**
 A meta for storing int values.
 Enables type casting to all types of ints.
 Only used during decoding.
 */
internal class FloatFormatMeta<BFP>: SimpleGenericMeta<BFP> where BFP: BinaryFloatingPoint {
    
    // only supports: Float and Double
    // no support for: Float80
    
    /**
     Cast this value to another kind of BinaryFloatingPoint.
     - Parameter allowLoosyConversion: specify, whether this method should throw an error, if the contained value could not be casted or whether it should approximate it.
     - Throws: if allowLoosyConversion was true, this method will throw MsgpackError.numberCouldNotBeConvertedWithoutLoss, if a number could not be converted without loss.
     */
    func castTo<OtherBFP>(allowLoosyConversion: Bool) throws -> OtherBFP? where OtherBFP: BinaryFloatingPoint {
        
        guard let value = self.value else {
            return nil
        }
        
        if allowLoosyConversion {
            
            // in this case, it actually doen't matter which type OtherBFP is, because they all support loosy initalization from the other types
            
            // the init() initalizers round to the closest possible representation
            
            if let floatValue = value as? Float {
                
                return OtherBFP(floatValue)
                
            } else {
                
                // this means value is Double
                // Float80 is not supported
                
                return OtherBFP(value as! Double)
                
            }
            
        } else { // do not approximate value
            
            // in this case we need to switch for value and for OtherBFT
            
            let exactValue: OtherBFP?
            
            if OtherBFP.self == Float.self {
                
                if let floatValue = value as? Float {
                    
                    // in this case value we don't need to check, whether value can be represented exactly
                    return (floatValue as! OtherBFP)
                    
                } else {
                    // this means value is Double
                    // in this case we need to check whether value can be converted exactly
                    exactValue = Float(exactly: value as! Double) as! OtherBFP?
                    
                }
                
            } else {
                
                // this means OtherBFP is Double
                // if not, this indicates a programming error in this framework (in MsgpackTranslator + Decoding Stage)
                
                if let doubleValue = value as? Double {
                    // double to double will never need approximation
                    return (Double(doubleValue) as! OtherBFP)
                    
                } else {
                    // this means value is Float
                    // in this case we need to check whether value can be converted exactly
                    exactValue = Double(exactly: value as! Float) as! OtherBFP?
                    
                }
                
            }
            
            if exactValue != nil {
                return exactValue!
            } else {
                // throw error, if the value could not be converted
                throw MsgpackError.numberCouldNotBeConvertedWithoutLoss(number: value)
            }
            
            
        }
        
    }
    
}
