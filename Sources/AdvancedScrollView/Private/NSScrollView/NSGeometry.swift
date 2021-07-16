//
//  NSGeometry.swift
//  
//
//  Created by Dmytro Anokhin on 16/07/2021.
//

#if os(macOS)

import AppKit

extension NSPoint {

    static func + (left: NSPoint, right: NSPoint) -> NSPoint {
        NSPoint(x: left.x + right.x, y: left.y + right.y)
    }
}

#endif
