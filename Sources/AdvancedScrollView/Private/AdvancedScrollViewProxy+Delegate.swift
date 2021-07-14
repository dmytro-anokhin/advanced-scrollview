//
//  AdvancedScrollViewProxy+Delegate.swift
//  
//
//  Created by Dmytro Anokhin on 14/07/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
extension AdvancedScrollViewProxy {

    final class Delegate {

        init() {
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

        var getIsLiveMagnify: (() -> Bool)!

        // Methods to call

        func performScrollTo(_ rect: CGRect, animated: Bool) {
            scrollTo(rect, animated)
        }

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

        var isLiveMagnify: Bool {
            getIsLiveMagnify()
        }
    }
}
