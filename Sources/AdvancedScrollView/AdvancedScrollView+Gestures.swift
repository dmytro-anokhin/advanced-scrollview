//
//  AdvancedScrollView+Gestures.swift
//  
//
//  Created by Dmytro Anokhin on 14/07/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
public typealias TapContentAction = (_ location: CGPoint, _ proxy: AdvancedScrollViewProxy) -> Void

@available(macOS 10.15, iOS 13.0, *)
public typealias DragContentAction = (_ state: ContinuousGestureState, _ location: CGPoint, _ translation: CGSize, _ proxy: AdvancedScrollViewProxy) -> Void


public enum ContinuousGestureState {

    case began

    case changed

    case cancelled

    case ended
}


@available(macOS 10.15, iOS 13.0, *)
public extension AdvancedScrollView {

    func onTapContentGesture(count: Int = 1, perform action: @escaping TapContentAction) -> AdvancedScrollView {
        self.gesturesDelegate.tapContentGestureInfo = TapContentGestureInfo(count: count, action: action)
        return self
    }

    func onDragContentGesture(perform action: @escaping DragContentAction) -> AdvancedScrollView {
        self.gesturesDelegate.dragContentGestureInfo = DragContentGestureInfo(action: action)
        return self
    }
}
