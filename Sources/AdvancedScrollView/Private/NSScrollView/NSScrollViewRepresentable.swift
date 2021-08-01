//
//  NSScrollViewRepresentable.swift
//
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

#if os(macOS)

import AppKit
import SwiftUI
import Combine


@available(macOS 10.15, *)
struct NSScrollViewRepresentable<Content: View>: NSViewRepresentable {

    let magnification: Magnification

    let hasScrollers: Bool

    let tapContentGestureInfo: TapContentGestureInfo?

    let dragContentGestureInfo: DragContentGestureInfo?

    let content: (_ proxy: AdvancedScrollViewProxy) -> Content

    init(magnification: Magnification,
         hasScrollers: Bool,
         tapContentGestureInfo: TapContentGestureInfo?,
         dragContentGestureInfo: DragContentGestureInfo?,
         @ViewBuilder content: @escaping (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.magnification = magnification
        self.hasScrollers = hasScrollers
        self.tapContentGestureInfo = tapContentGestureInfo
        self.dragContentGestureInfo = dragContentGestureInfo
        self.content = content
    }

    func makeNSView(context: Context) -> NSScrollViewSubclass {
        let scrollView = NSScrollViewSubclass()
        scrollView.minMagnification = magnification.range.lowerBound
        scrollView.maxMagnification = magnification.range.upperBound
        scrollView.magnification = magnification.initialValue

        scrollView.hasHorizontalScroller = hasScrollers
        scrollView.hasVerticalScroller = hasScrollers
        scrollView.allowsMagnification = true

        let clipView = NSClipViewSubclass()
        scrollView.contentView = clipView

        if let tapContentGestureInfo = tapContentGestureInfo {
            scrollView.onClickGesture(count: tapContentGestureInfo.count) { [unowned scrollView] location in
                let proxy = makeProxy(scrollView: scrollView)
                tapContentGestureInfo.action(location, proxy)
            }
        }

        if let dragContentGestureInfo = dragContentGestureInfo {
            scrollView.onPanGesture { [unowned scrollView] state, location, translation in
                let proxy = makeProxy(scrollView: scrollView)
                let translation = CGSize(width: translation.x, height: translation.y)
                return dragContentGestureInfo.action(state, location, translation, proxy)
            }
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollViewSubclass, context: Context) {
        let proxy = makeProxy(scrollView: nsView)
        let contentView = content(proxy)

        if let hostingView = nsView.documentView as? NSHostingViewSubclass<Content> {
            hostingView.rootView = contentView
        } else {
            let hostingView = NSHostingViewSubclass(rootView: contentView)
            nsView.documentView = hostingView
        }

        if let documentView = nsView.documentView {
            let size = documentView.fittingSize
            documentView.frame = CGRect(origin: .zero, size: size)
        }
    }

    // MARK - Private

    private func makeProxy(scrollView: NSScrollViewSubclass) -> AdvancedScrollViewProxy {
        var proxy = AdvancedScrollViewProxy()

        proxy.performScrollTo = { rect, animated in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            scrollView.scroll(center)
        }

        proxy.getContentOffset = {
            scrollView.contentView.bounds.origin
        }

        proxy.setContentOffset = { contentOffset in
            let point = scrollView.contentView.convert(contentOffset, to: scrollView.documentView)
            scrollView.documentView?.scroll(point)
        }

        proxy.getContentSize = {
            scrollView.documentView?.bounds.size ?? .zero
        }

        proxy.getContentInset = {
            EdgeInsets(scrollView.contentInsets)
        }

        proxy.setContentInset = {
            scrollView.contentInsets = NSEdgeInsets($0)
        }

        proxy.getVisibleRect = {
            scrollView.documentVisibleRect
        }

        proxy.getScrollerInsets = {
            EdgeInsets(scrollView.scrollerInsets)
        }

        proxy.getMagnification = {
            scrollView.magnification
        }

        proxy.getIsLiveMagnify = {
            scrollView.isLiveMagnify
        }

        proxy.getIsAutoscrollEnabled = {
            scrollView.isAutoscrollEnabled
        }

        proxy.setIsAutoscrollEnabled = {
            scrollView.isAutoscrollEnabled = $0
        }

        return proxy
    }
}

#endif
