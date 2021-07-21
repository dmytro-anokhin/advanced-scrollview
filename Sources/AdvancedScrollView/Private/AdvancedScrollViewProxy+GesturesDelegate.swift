//
//  AdvancedScrollViewProxy+GesturesDelegate.swift
//  
//
//  Created by Dmytro Anokhin on 14/07/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
extension AdvancedScrollViewProxy {

    final class GesturesDelegate {

        static let shared = GesturesDelegate()

        init() {
        }

        var tapContentGestureInfo: TapContentGestureInfo?

        var dragContentGestureInfo: DragContentGestureInfo?
    }
}
