# Compatibility
## Decoding
All types will always be able to decode from both variants presented here, no matter which option is set.
## Dictionarys
Dictionarys encoded as Arrays (which is the default for dictionarys with keys of diffrent types than String and Int) are not decodable by msgpack-java.

The option encodeDictionarysJavaCompatibel (set by default) fixes this, by encoding any dictionary as map, but those values won't be compatibel to most other swift msgpack libraries with Codable support.
### Dictionary features
 - Encode and decode dictionarys as arrays (encoding only when encodeDictionarysJavaCompatibel option set to false)
 - Encode and decode dictionarys as maps
 - Encode all keys of a dictionary as String and decoding Bool, Float, Double and all Ints/UInts from strings keys
 ### Maps (in java)
As far as I could check it, keys are always encoded as strings.
 - msgpack-java is able to decode maps of keys diffrent than strings (tested for double) to Map.
 - msgpack-java has no ability to decode maps with complex objects as keys (e.g. Banana in the tests) by default.
## Data and [UInt8]
Data and [UInt8] are treated equaliy (since they also encode in equal ways by default).

The option encodeDataAsBinary (set by default) changes the default encoding behavior of Data. If set, Data and also [UInt8] will encode as msgpack binary, if not set, Data will encode as msgpack-array.
