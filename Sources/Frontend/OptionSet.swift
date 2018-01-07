//
//  OptionSet.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 25.11.17.
//

import Foundation

/**
 A configuration for this framework.
 With this options you give some more additionaly information to this framework, how to handle certain values and cases.
 All options have a default value.
 */
public struct Configuration {
    
    /**
     Indicates, wheather to throw an error if an encoded numeric value is not compatibel to the requested Swift Type (e.g. encoded int16 should be turned into int8), or round respectively clamp to make the value fitting (this is indicated by a value of true).
     
     Default is false.
     */
    public var allowLoosyNumberConversion: Bool
    
    /**
     Indicates, wheather to throw an error if an encoded floating point numeric value is not compatibel to the requested Swift Type (encoded double should be turned into float), or round to make the value fitting (this is indicated by a value of true).
     
     Default is false.
     */
    public var allowLoosyFloatingPointNumberConversion: Bool
    
    /**
     Indicates whether to throw an error if a string can not be converted to utf8 without loss
     
     Default is false.
     */
    public var allowLoosyStringConversion: Bool
    
    /**
     Indicates whether the Date type from the swift standard library should be (possile loosy) converted to the msgpack timestamp extension (that will be cross platform operatable). Most swift dates will be converted without loss, but some verry precise (preciser than nano seconds) values will lose precission.
     If this option is set to false, Date's own coding capabilites will be used.
     
     Default is true.
     */
    public var convertSwiftDateToMsgpackTimestamp: Bool
    
    /**
     Indicates whether arbitrary Dictionarys should be encoded equally as java.util.Map is encoded by msgpack-java, or whether they should be encoded in the way Dictionary encoded itself.
     The results of both options will differ on Dictionarsy with complex swift entities as keys.
     
     Default is true.
     */
    public var encodeDictionarysJavaCompatibel: Bool
    
    /**
     Indicates whether Data instances should be encoded to the binary type of msgpack, or if they should be encoded in the way they encode themselves (as array).
     
     Default is true.
     */
    public var encodeDataAsBinary: Bool
    
    public init( allowLoosyNumberConversion: Bool = false,
                 allowLoosyFloatingPointNumberConversion: Bool = false,
                 allowLoosyStringConversion: Bool = false,
                 convertSwiftDateToMsgpackTimestamp: Bool = true,
                 encodeDictionarysJavaCompatibel: Bool = true,
                 encodeDataAsBinary: Bool = true ) {
        
        self.allowLoosyNumberConversion = allowLoosyNumberConversion
        self.allowLoosyFloatingPointNumberConversion = allowLoosyFloatingPointNumberConversion
        self.allowLoosyStringConversion = allowLoosyStringConversion
        self.convertSwiftDateToMsgpackTimestamp = convertSwiftDateToMsgpackTimestamp
        self.encodeDictionarysJavaCompatibel = encodeDictionarysJavaCompatibel
        self.encodeDataAsBinary = encodeDataAsBinary
        
    }
    
}
