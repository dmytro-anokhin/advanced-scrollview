//
//  NSScrollViewWrapper.swift
//  
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

#if os(macOS)

import AppKit
import SwiftUI
import Combine


@available(macOS 10.15, *)
struct NSScrollViewWrapper<Content: View>: NSViewRepresentable {

    let magnification: Magnification

    let hasScrollers: Bool

    let content: Content

    let proxyDelegate: AdvancedScrollViewProxy.Delegate

    init(magnification: Magnification,
         hasScrollers: Bool,
         proxyDelegate: AdvancedScrollViewProxy.Delegate,
         @ViewBuilder content: () -> Content) {
        self.magnification = magnification
        self.hasScrollers = hasScrollers
        self.proxyDelegate = proxyDelegate
        self.content = content()
    }

    func makeNSView(context: Context) -> NSScrollView {
        context.coordinator.scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        proxyDelegate.scrollTo = { rect, animated in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            nsView.scroll(center)
        }

        proxyDelegate.getContentOffset = {
            nsView.contentView.bounds.origin
        }

        proxyDelegate.setContentOffset = { contentOffset in
            let point = nsView.contentView.convert(contentOffset, to: nsView.documentView)
            nsView.documentView?.scroll(point)
        }

        proxyDelegate.getContentSize = {
            nsView.documentView?.bounds.size ?? .zero
        }

        proxyDelegate.getContentInset = {
            EdgeInsets(nsView.contentInsets)
        }

        proxyDelegate.setContentInset = {
            nsView.contentInsets = NSEdgeInsets($0)
        }

        proxyDelegate.getVisibleRect = {
            nsView.documentVisibleRect
        }

        proxyDelegate.getScrollerInsets = {
            EdgeInsets(nsView.scrollerInsets)
        }

        proxyDelegate.getMagnification = {
            nsView.magnification
        }

        context.coordinator.hostingView.rootView = content

        let size = context.coordinator.hostingView.fittingSize
        context.coordinator.hostingView.frame = CGRect(origin: .zero, size: size)
    }

    class Coordinator: NSObject {

        let hostingView: NSHostingView<Content>

        var parent: NSScrollViewWrapper

        init(parent: NSScrollViewWrapper) {
            self.hostingView = NSHostingView(rootView: parent.content)
            self.parent = parent
        }

        var scrollView: NSScrollView {
            let scrollView = NSScrollView()
            scrollView.minMagnification = parent.magnification.range.lowerBound
            scrollView.maxMagnification = parent.magnification.range.upperBound
            scrollView.magnification = parent.magnification.initialValue

            scrollView.hasHorizontalScroller = parent.hasScrollers
            scrollView.hasVerticalScroller = parent.hasScrollers
            scrollView.allowsMagnification = true

            let clipView = NSClipView()
            scrollView.contentView = clipView
            scrollView.documentView = hostingView

            return scrollView
        }

        private var cancellables = Set<AnyCancellable>()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

#endif
