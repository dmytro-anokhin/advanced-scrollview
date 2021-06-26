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

    let magnificationRange: ClosedRange<CGFloat>

    @Binding var magnification: CGFloat

    let hasScrollers: Bool

    let content: Content

    let proxyDelegate: AdvancedScrollViewProxy.Delegate

    init(magnificationRange: ClosedRange<CGFloat>,
         magnification: Binding<CGFloat>,
         hasScrollers: Bool,
         proxyDelegate: AdvancedScrollViewProxy.Delegate,
         @ViewBuilder content: () -> Content) {
        self.magnificationRange = magnificationRange
        self._magnification = magnification
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

        context.coordinator.hostingView.rootView = content

        let size = context.coordinator.hostingView.fittingSize
        context.coordinator.hostingView.frame = CGRect(origin: .zero, size: size)

        nsView.magnification = magnification
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
            scrollView.minMagnification = parent.magnificationRange.lowerBound
            scrollView.maxMagnification = parent.magnificationRange.upperBound
            scrollView.magnification = parent.magnification

            scrollView.hasHorizontalScroller = parent.hasScrollers
            scrollView.hasVerticalScroller = parent.hasScrollers
            scrollView.allowsMagnification = true

            let clipView = NSClipView()
            scrollView.contentView = clipView
            scrollView.documentView = hostingView

            scrollView
                .publisher(for: \.magnification)
                .debounce(for: 0.0, scheduler: RunLoop.main) // Debounce to the next run loop iteration
                .sink { [weak self] magnification in
                    guard let self = self else {
                        return
                    }

                    self.parent.magnification = magnification
                }
                .store(in: &cancellables)

            return scrollView
        }

        private var cancellables = Set<AnyCancellable>()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

#endif
