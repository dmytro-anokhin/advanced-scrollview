//
//  AdvancedScrollView+Gestures.swift
//  
//
//  Created by Dmytro Anokhin on 14/07/2021.
//

import SwiftUI

/// Action for tap gesture
///
/// - Parameters:
///     - location: Location in the content view coordinates.
///     - proxy: Scroll view proxy.
@available(macOS 10.15, iOS 13.0, *)
public typealias TapContentAction = (_ location: CGPoint, _ proxy: AdvancedScrollViewProxy) -> Void

/// Action for drag (pan) gesture
///
/// - Parameters:
///     - state: The state of the gesture. See `ContinuousGestureState` for reference.
///     - location: Location in the content view coordinates.
///     - translation: The distance traveled by the pointer during the gesture.
///
/// - Returns:
///     Should return `true` if the scroll view should adjust content offset to keep the pointer inside its visible rect.
@available(macOS 10.15, iOS 13.0, *)
public typealias DragContentAction = (_ state: ContinuousGestureState, _ location: CGPoint, _ translation: CGSize, _ proxy: AdvancedScrollViewProxy) -> Bool


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
