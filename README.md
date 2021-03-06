# swift-msgpack-serialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Another swift serialization library for msgpack with support for the Codable environement.

This framework is designed to be (optionaly) compatibel to the msgpack-java library.
See [Compatibility.md](https://github.com/cherrywoods/swift-msgpack-serialization/blob/master/Compatibility.md) for more detailed information about this.

Please make sure, that the swift model classes and java model classes you use are compatibel to each other, e.g. enums are named equaly (including case).

This framework also supplies the possibiliy to encode keys of other types than String (generalContainer function of MsgpackEncoder).

swift-msgpack-serialization works with [MessagePack.swift](https://github.com/a2/MessagePack.swift). This means, that you can encode your classes, structs and enums, that conform to Codable to MessagePackValue from MessagePack.swift, do something with this MessagePackValue and then encode it to msgpack using MessagePack.swift. You may of course also decode to MessagePackValue first and then decode a particular MessagePackValue to your own type. 
## Instalation
Currently, only carthage is supported.

## Compatibilty restrictions
Make sure you never call .encode(to:) directly! Instead use the encode method on a keyed, unkeyed or singleValue container or cast the encoder passed to you to MsgpackEncoder and call encodeIntermediate(_) on this encoder. If you do not use this, this framework won't be able to do it's work properly.
