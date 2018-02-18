//
//  Reference.swift
//  SwiftMsgpackSerialization
//
//  Created by cherrywoods on 12.01.18.
//

import Foundation
import MetaSerialization

internal struct GeneralContainerReference: ContainerReference {
    
    internal var coder: MetaCoder
    internal var element: Meta {
        get {
            return mapMeta
        }
        set {
            if let meta = newValue as? MapMeta {
                mapMeta = meta
            }
        }
    }
    
    private var mapMeta: MapMeta
    internal let key: Meta
    
    internal var codingKey: CodingKey = GeneralCodingKey()
    
    internal init(coder: MetaCoder, element: MapMeta, at key: Meta) {
        self.coder = coder
        self.mapMeta = element
        self.key = key
    }
    
    internal mutating func insert(_ value: Meta) {
        
        mapMeta.add(key: key, value: value)
        
    }
    
}
