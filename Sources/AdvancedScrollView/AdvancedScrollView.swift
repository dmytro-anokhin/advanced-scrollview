//
//  AdvancedScrollView.swift
//
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

import SwiftUI


public struct AdvancedScrollViewProxy {

    final class Delegate {

        init() {
        }

        fileprivate func performScrollTo(_ rect: CGRect, animated: Bool) {
            scrollTo(rect, animated)
        }

        var scrollTo: ((_ rect: CGRect, _ animated: Bool) -> Void)!
    }

    var delegate: Delegate

    public func scrollTo(_ rect: CGRect, animated: Bool) {
        delegate.performScrollTo(rect, animated: animated)
    }
}


@available(macOS 10.15, iOS 13.0, *)
public struct AdvancedScrollView<Content: View>: View {

    let magnificationRange: ClosedRange<CGFloat>

    @Binding var magnification: CGFloat

    let content: Content

    public init(magnificationRange: ClosedRange<CGFloat> = 1.0...1.0, magnification: CGFloat = 1.0, @ViewBuilder content: (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.init(magnificationRange: magnificationRange, magnification: .constant(magnification), content: content)
    }

    public init(magnificationRange: ClosedRange<CGFloat> = 1.0...1.0, magnification: Binding<CGFloat>, @ViewBuilder content: (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.magnificationRange = magnificationRange
        self._magnification = magnification
        self.content = content(AdvancedScrollViewProxy(delegate: proxyDelegate))
    }

    public var body: some View {
        #if os(macOS)
        NSScrollViewWrapper(magnificationRange: magnificationRange, magnification: $magnification, proxyDelegate: proxyDelegate, content: { content })
        #else
        UIScrollViewWrapper(zoomScaleRange: magnificationRange, zoomScale: $magnification, proxyDelegate: proxyDelegate, content: { content })
        #endif
    }

    private let proxyDelegate = AdvancedScrollViewProxy.Delegate()
}
