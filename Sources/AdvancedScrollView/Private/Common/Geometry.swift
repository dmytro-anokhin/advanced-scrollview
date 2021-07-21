//
//  Geometry.swift
//  
//
//  Created by Dmytro Anokhin on 24/06/2021.
//

import CoreGraphics


extension CGSize {

    static var greatestFiniteMagnitude: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}


extension CGPoint {

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}
