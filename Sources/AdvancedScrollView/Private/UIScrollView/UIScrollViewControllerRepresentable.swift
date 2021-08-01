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

    let tapContentGestureInfo: TapContentGestureInfo?

    let dragContentGestureInfo: DragContentGestureInfo?

    let content: (_ proxy: AdvancedScrollViewProxy) -> Content

    init(magnification: Magnification,
         isScrollIndicatorVisible: Bool,
         tapContentGestureInfo: TapContentGestureInfo?,
         dragContentGestureInfo: DragContentGestureInfo?,
         @ViewBuilder content: @escaping (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.magnification = magnification
        self.isScrollIndicatorVisible = isScrollIndicatorVisible
        self.tapContentGestureInfo = tapContentGestureInfo
        self.dragContentGestureInfo = dragContentGestureInfo
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewController {
        UIScrollViewController(minimumZoomScale: magnification.range.lowerBound,
                               maximumZoomScale: magnification.range.upperBound,
                               zoomScale: magnification.initialValue,
                               isZoomRelative: magnification.isRelative,
                               isScrollIndicatorVisible: isScrollIndicatorVisible)
    }

    func updateUIViewController(_ uiViewController: UIScrollViewController, context: Context) {
        let proxy = makeProxy(scrollViewController: uiViewController)
        let contentView = content(proxy)

        if uiViewController.contentViewController == nil {
            let hostingController = UIHostingController(rootView: contentView)
            uiViewController.contentViewController = hostingController

            if let tapContentGestureInfo = tapContentGestureInfo {
                uiViewController.onTapGesture(count: tapContentGestureInfo.count) { location in
                    tapContentGestureInfo.action(location, proxy)
                }
            }

            if let dragContentGestureInfo = dragContentGestureInfo {
                uiViewController.onPanGesture { state, location, translation in
                    let translation = CGSize(width: translation.x, height: translation.y)
                    return dragContentGestureInfo.action(state, location, translation, proxy)
                }
            }
        } else {
            (uiViewController.contentViewController as! UIHostingController<Content>).rootView = contentView
        }
    }

    // MARK - Private
    private func makeProxy(scrollViewController: UIScrollViewController) -> AdvancedScrollViewProxy {
        var proxy = AdvancedScrollViewProxy()

        proxy.performScrollTo = { rect, animated in
            scrollViewController.scrollTo(rect, animated: animated)
        }

        proxy.getContentOffset = {
            scrollViewController.scrollView.contentOffset
        }

        proxy.setContentOffset = {
            scrollViewController.scrollView.contentOffset = $0
        }

        proxy.getContentSize = {
            scrollViewController.scrollView.contentSize
        }

        proxy.getContentInset = {
            EdgeInsets(scrollViewController.scrollView.contentInset)
        }

        proxy.setContentInset = {
            scrollViewController.scrollView.contentInset = UIEdgeInsets($0)
        }

        proxy.getVisibleRect = {
            scrollViewController.scrollView.bounds
        }

        proxy.getScrollerInsets = {
            EdgeInsets()
        }

        proxy.getMagnification = {
            scrollViewController.scrollView.zoomScale
        }

        proxy.getIsLiveMagnify = {
            scrollViewController.scrollView.isZooming || scrollViewController.scrollView.isZoomBouncing
        }

        proxy.getIsAutoscrollEnabled = {
            false
        }

        proxy.setIsAutoscrollEnabled = { _ in
        }

        return proxy
    }

//    class Coordinator: NSObject, UIScrollViewControllerDelegate {
//
//        let hostingController: UIHostingController<Content>
//
//        var parent: UIScrollViewControllerRepresentable
//
//        init(parent: UIScrollViewControllerRepresentable) {
//            self.hostingController = UIHostingController(rootView: parent.content)
//            self.parent = parent
//        }
//
//        func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat) {
//            // TODO: Pass value up the hierarchy using binding
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
}

#endif
