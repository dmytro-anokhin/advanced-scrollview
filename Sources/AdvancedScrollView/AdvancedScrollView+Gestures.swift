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
///     - phase: The phase of the gesture. See `ContinuousGesturePhase` for reference.
///     - location: Location in the content view coordinates.
///     - translation: The distance traveled by the pointer during the gesture.
///
/// - Returns:
///     Should return `true` if content can be dragged.
@available(macOS 10.15, iOS 13.0, *)
public typealias DragContentAction = (_ phase: ContinuousGesturePhase, _ location: CGPoint, _ translation: CGSize, _ proxy: AdvancedScrollViewProxy) -> Bool


public enum ContinuousGesturePhase {

    /// Received touch events, but the gesture has not yet been recognized.
    ///
    /// Related action handler can return `false` to cancel gesture recognition.
    case possible

    case began

    case changed

    case cancelled

    case ended
}


@available(macOS 10.15, iOS 13.0, *)
public extension AdvancedScrollView {

    func onTapContentGesture(count: Int = 1, perform action: @escaping TapContentAction) -> AdvancedScrollView {
        let tapContentGestureInfo = TapContentGestureInfo(count: count, action: action)
        return AdvancedScrollView(magnification: magnification,
                                  isScrollIndicatorVisible: isScrollIndicatorVisible,
                                  tapContentGestureInfo: tapContentGestureInfo,
                                  dragContentGestureInfo: dragContentGestureInfo,
                                  content: content)
    }

    func onDragContentGesture(perform action: @escaping DragContentAction) -> AdvancedScrollView {
        let dragContentGestureInfo = DragContentGestureInfo(action: action)
        return AdvancedScrollView(magnification: magnification,
                                  isScrollIndicatorVisible: isScrollIndicatorVisible,
                                  tapContentGestureInfo: tapContentGestureInfo,
                                  dragContentGestureInfo: dragContentGestureInfo,
                                  content: content)
    }
}
