//
//  UIScrollViewControllerRepresentable.swift
//  
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

#if !os(macOS)

import UIKit
import SwiftUI


@available(iOS 13.0, *)
struct UIScrollViewControllerRepresentable<Content: View>: UIViewControllerRepresentable {

    let magnification: Magnification

    let isScrollIndicatorVisible: Bool

    let content: Content

    let proxyDelegate: AdvancedScrollViewProxy.Delegate

    let proxyGesturesDelegate: AdvancedScrollViewProxy.GesturesDelegate

    init(magnification: Magnification,
         isScrollIndicatorVisible: Bool,
         proxyDelegate: AdvancedScrollViewProxy.Delegate,
         proxyGesturesDelegate: AdvancedScrollViewProxy.GesturesDelegate,
         @ViewBuilder content: () -> Content) {
        self.magnification = magnification
        self.isScrollIndicatorVisible = isScrollIndicatorVisible
        self.proxyDelegate = proxyDelegate
        self.proxyGesturesDelegate = proxyGesturesDelegate
        self.content = content()
    }

    func makeUIViewController(context: Context) -> UIScrollViewController {
        let scrollViewController = UIScrollViewController(contentViewController: context.coordinator.hostingController,
                                                          minimumZoomScale: magnification.range.lowerBound,
                                                          maximumZoomScale: magnification.range.upperBound,
                                                          zoomScale: magnification.initialValue,
                                                          isZoomRelative: magnification.isRelative,
                                                          isScrollIndicatorVisible: isScrollIndicatorVisible)
        scrollViewController.delegate = context.coordinator

        proxyDelegate.scrollTo = { rect, animated in
            scrollViewController.scrollTo(rect, animated: animated)
        }

        proxyDelegate.getContentOffset = {
            scrollViewController.scrollView.contentOffset
        }

        proxyDelegate.setContentOffset = {
            scrollViewController.scrollView.contentOffset = $0
        }

        proxyDelegate.getContentSize = {
            scrollViewController.scrollView.contentSize
        }

        proxyDelegate.getContentInset = {
            EdgeInsets(scrollViewController.scrollView.contentInset)
        }

        proxyDelegate.setContentInset = {
            scrollViewController.scrollView.contentInset = UIEdgeInsets($0)
        }

        proxyDelegate.getVisibleRect = {
            scrollViewController.scrollView.bounds
        }

        proxyDelegate.getScrollerInsets = {
            EdgeInsets()
        }

        proxyDelegate.getMagnification = {
            scrollViewController.scrollView.zoomScale
        }

        proxyDelegate.getIsLiveMagnify = {
            scrollViewController.scrollView.isZooming || scrollViewController.scrollView.isZoomBouncing
        }

        if let tapContentGestureInfo = proxyGesturesDelegate.tapContentGestureInfo {
            scrollViewController.onTapGesture(count: tapContentGestureInfo.count) { location in
                let proxy = AdvancedScrollViewProxy(delegate: proxyDelegate)
                tapContentGestureInfo.action(location, proxy)
            }
        }

        if let dragContentGestureInfo = proxyGesturesDelegate.dragContentGestureInfo {
            scrollViewController.onPanGesture { state, location, translation in
                let translation = CGSize(width: translation.x, height: translation.y)
                let proxy = AdvancedScrollViewProxy(delegate: proxyDelegate)
                return dragContentGestureInfo.action(state, location, translation, proxy)
            }
        }

        return scrollViewController
    }

    func updateUIViewController(_ uiViewController: UIScrollViewController, context: Context) {
        context.coordinator.hostingController.rootView = content
    }

    class Coordinator: NSObject, UIScrollViewControllerDelegate {

        let hostingController: UIHostingController<Content>

        var parent: UIScrollViewControllerRepresentable

        init(parent: UIScrollViewControllerRepresentable) {
            self.hostingController = UIHostingController(rootView: parent.content)
            self.parent = parent
        }

        func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat) {
            // TODO: Pass value up the hierarchy using binding
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}


#endif
