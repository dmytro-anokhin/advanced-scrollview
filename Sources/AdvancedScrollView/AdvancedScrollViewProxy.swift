//
//  AdvancedScrollViewProxy.swift
//  
//
//  Created by Dmytro Anokhin on 28/06/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
public struct AdvancedScrollViewProxy {

    init(delegate: Delegate) {
        self.delegate = delegate
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

    public var isLiveMagnify: Bool {
        delegate.getIsLiveMagnify()
    }
}
