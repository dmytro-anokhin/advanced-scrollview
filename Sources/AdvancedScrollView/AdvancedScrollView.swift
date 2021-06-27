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

    public let magnification: Magnification

    public let isScrollIndicatorVisible: Bool

    let content: Content

    public init(magnification: Magnification = Magnification(range: 1.0...4.0, initialValue: 1.0, isRelative: true),
                isScrollIndicatorVisible: Bool = true,
                @ViewBuilder content: (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.magnification = magnification
        self.isScrollIndicatorVisible = isScrollIndicatorVisible
        self.content = content(AdvancedScrollViewProxy(delegate: proxyDelegate))
    }

    public var body: some View {
        #if os(macOS)
        NSScrollViewWrapper(magnification: magnification,
                            hasScrollers: isScrollIndicatorVisible,
                            proxyDelegate: proxyDelegate,
                            content: {
                                content
                            })
        #else
        UIScrollViewWrapper(magnification: magnification,
                            isScrollIndicatorVisible: isScrollIndicatorVisible,
                            proxyDelegate: proxyDelegate,
                            content: {
                                content
                            })
        #endif
    }

    private let proxyDelegate = AdvancedScrollViewProxy.Delegate()
}
