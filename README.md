# swift-msgpack-serialization
Another swift serialization library

This framework is designed to be compatibel to the msgpack-java library.

The main feature now is that it converts all kinds of dictionarys to the msgpack map type, as java does with java.util.Maps, so that these two types are compatibel.

Please note, that you still needs to make sure, that the swift model classes and java model classes you use are compatibel to each other, e.g. enums are named equaly (also case, etc.)

## Compatibilty restrictions
This framwork can not encode nested dictionarys with keys of diffrent type than String or Int in a java-compatibel way.
If you have such nested dictionarys in your own classes, make sure you don't call .encode(to:)! Cast the encoder passed to you to MsgpackEncoder instead and call encodeIntermediate(_) on this encoder instead or the encode method on a keyed, unkeyed or singlevalue container. If you do this your ('first level') dictionarys will be encoded properly (if they don't have any nested dictionarys).
The same does not apply on decoding. Decoding nested maps to dictionarys works fine,

The same applies to Data and byte arrays. 
