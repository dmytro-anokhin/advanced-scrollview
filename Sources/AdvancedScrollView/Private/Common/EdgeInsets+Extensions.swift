//
//  EdgeInsets+Extensions.swift
//  
//
//  Created by Dmytro Anokhin on 07/07/2021.
//

import SwiftUI


#if canImport(AppKit)

import AppKit

@available(macOS 10.15, *)
extension EdgeInsets {

    init(_ nsEdgeInsets: NSEdgeInsets) {
        self.init(top: nsEdgeInsets.top, leading: nsEdgeInsets.left, bottom: nsEdgeInsets.bottom, trailing: nsEdgeInsets.right)
    }
}

@available(macOS 10.15, *)
extension NSEdgeInsets {

    init(_ edgeInsets: EdgeInsets) {
        self.init(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
    }
}

#endif


#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
extension EdgeInsets {

    init(_ uiEdgeInsets: UIEdgeInsets) {
        self.init(top: uiEdgeInsets.top, leading: uiEdgeInsets.left, bottom: uiEdgeInsets.bottom, trailing: uiEdgeInsets.right)
    }
}

@available(iOS 13.0, *)
extension UIEdgeInsets {

    init(_ edgeInsets: EdgeInsets) {
        self.init(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
    }
}

#endif
