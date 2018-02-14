//
//  Msgpacks.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 14.02.18.
//

import Foundation
import MetaSerialization
import MessagePack

extension Data: Msgpack {}

// using MessagePackValue for encoding and decoding is supported
extension MessagePackValue: Msgpack {}

// TODO: support streams
