//
//  AdvancedScrollViewProxy.swift
//  
//
//  Created by Dmytro Anokhin on 28/06/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
public struct AdvancedScrollViewProxy {

    init() {
    }

    public func scrollTo(_ rect: CGRect, animated: Bool) {
        performScrollTo(rect, animated)
    }

    public var contentOffset: CGPoint {
        get {
            getContentOffset()
        }

        set {
            setContentOffset(newValue)
        }
    }

    /// Content size is read-only on macOS so it is here
    public var contentSize: CGSize {
        getContentSize()
    }

    public var contentInset: EdgeInsets {
        get {
            getContentInset()
        }

        set {
            setContentInset(newValue)
        }
    }

    public var visibleRect: CGRect {
        getVisibleRect()
    }

    public var scrollerInsets: EdgeInsets {
        getScrollerInsets()
    }

    public var magnification: CGFloat {
        getMagnification()
    }

    public var isLiveMagnify: Bool {
        getIsLiveMagnify()
    }

    public var isAutoscrollEnabled: Bool {
        get {
            getIsAutoscrollEnabled()
        }

        set {
            setIsAutoscrollEnabled(newValue)
        }
    }

    // MARK: - Internal

    var performScrollTo: ((_ rect: CGRect, _ animated: Bool) -> Void)!

    var getContentOffset: (() -> CGPoint)!
    var setContentOffset: ((_ contentOffset: CGPoint) -> Void)!

    var getContentSize: (() -> CGSize)!

    var getContentInset: (() -> EdgeInsets)!
    var setContentInset: ((_ contentInset: EdgeInsets) -> Void)!

    var getVisibleRect: (() -> CGRect)!

    var getScrollerInsets: (() -> EdgeInsets)!

    var getMagnification: (() -> CGFloat)!

    var getIsLiveMagnify: (() -> Bool)!

    var getIsAutoscrollEnabled: (() -> Bool)!
    var setIsAutoscrollEnabled: ((_ isAutoscrollEnabled: Bool) -> Void)!
}
