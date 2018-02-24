//
//  Errors.swift
//  swift-msgpack-serialization-iOS
//
//  Created by cherrywoods on 31.10.17.
//

import Foundation

// assembles various errors thrown during encoding to msgpack and decoding from msgpack
public enum MsgpackError: Error {
    
    /// indicates, that some kind of container contained more than 2^32-1 elements. (Might be used in context of String, Data, Array, Dictionary and MsgpackExtension)
    case valueExceededSupportedLength
    
    /// Thrown if you specify .allowLoosyNumberConversion or .allowLoosyFloatingPointNumberConversion as false in the coding options. number will always be a Numeric.
    case numberCouldNotBeConvertedWithoutLoss(number: Any)
    
    /// Thrown if a certain chunk of data (passed with rawData) could not be decoded using utf8. 
    case invalidStringData(rawData: Data)
    
    /// Thrown if a certain msgpack timestamp value could not be converted to Date
    case timestampUnconvertibleToDate
    
    /**
     Thrown if a Date wasn't convertible to msgpack timestamp, but was tried to be encoded as timestamp.
     This may happen, if a date's timeIntervalSince1970 property had a precision beyond nano seconds
     (timestamp does not allow precisions beyond nano seconds),
     or if it was to large or to small to be represented as Int64.
     
     If you wan't to encode such values, change the Configuration to use Date's own encoding capabilities
     (set convertSwiftDateToMsgpackTimestamp to false).
     */
    case dateUnconvertibleToTimestamp
    
    /// Thrown if a certain Data object is no valid msgpack code.
    case invalidMsgpack
    
    /// Thrown if data was passed to this framework, that can not be handled by it.
    case unknownMsgpack
    
}
