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
