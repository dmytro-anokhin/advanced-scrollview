//
//  AdvancedScrollViewProxy.swift
//  
//
//  Created by Dmytro Anokhin on 28/06/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
public struct AdvancedScrollViewProxy {

    final class Delegate {

        init() {
        }

        fileprivate func performScrollTo(_ rect: CGRect, animated: Bool) {
            scrollTo(rect, animated)
        }

        // Closures implemented by scroll view wrappers

        var scrollTo: ((_ rect: CGRect, _ animated: Bool) -> Void)!

        var getContentOffset: (() -> CGPoint)!
        var setContentOffset: ((_ contentOffset: CGPoint) -> Void)!

        var getContentSize: (() -> CGSize)!

        var getContentInset: (() -> EdgeInsets)!
        var setContentInset: ((_ contentInset: EdgeInsets) -> Void)!

        var getVisibleRect: (() -> CGRect)!

        var getScrollerInsets: (() -> EdgeInsets)!

        var getMagnification: (() -> CGFloat)!

        var contentOffset: CGPoint {
            get {
                getContentOffset()
            }

            set {
                setContentOffset(newValue)
            }
        }

        var contentSize: CGSize {
            getContentSize()
        }

        var contentInset: EdgeInsets {
            get {
                getContentInset()
            }

            set {
                setContentInset(newValue)
            }
        }

        var visibleRect: CGRect {
            getVisibleRect()
        }

        var scrollerInsets: EdgeInsets {
            getScrollerInsets()
        }

        var magnification: CGFloat {
            getMagnification()
        }
    }

    var delegate: Delegate

    public func scrollTo(_ rect: CGRect, animated: Bool) {
        delegate.performScrollTo(rect, animated: animated)
    }

    public var contentOffset: CGPoint {
        get {
            delegate.contentOffset
        }

        set {
            delegate.contentOffset = newValue
        }
    }

    /// Content size is read-only on macOS so it is here
    public var contentSize: CGSize {
        delegate.contentSize
    }

    public var contentInset: EdgeInsets {
        get {
            delegate.contentInset
        }

        set {
            delegate.contentInset = newValue
        }
    }

    public var visibleRect: CGRect {
        delegate.visibleRect
    }

    public var scrollerInsets: EdgeInsets {
        delegate.scrollerInsets
    }

    public var magnification: CGFloat {
        delegate.magnification
    }
}
