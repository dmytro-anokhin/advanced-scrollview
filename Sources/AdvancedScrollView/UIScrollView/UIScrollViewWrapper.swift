//
//  UIScrollViewWrapper.swift
//  
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

#if !os(macOS)

import UIKit
import SwiftUI


@available(iOS 13.0, *)
struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {

    let magnification: Magnification

    let isScrollIndicatorVisible: Bool

    let content: Content

    let proxyDelegate: AdvancedScrollViewProxy.Delegate

    init(magnification: Magnification,
         isScrollIndicatorVisible: Bool,
         proxyDelegate: AdvancedScrollViewProxy.Delegate,
         @ViewBuilder content: () -> Content) {
        self.magnification = magnification
        self.isScrollIndicatorVisible = isScrollIndicatorVisible
        self.proxyDelegate = proxyDelegate
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

        return scrollViewController
    }

    func updateUIViewController(_ uiViewController: UIScrollViewController, context: Context) {
        proxyDelegate.scrollTo = { rect, animated in
            uiViewController.scrollTo(rect, animated: animated)
        }

        proxyDelegate.getContentOffset = {
            uiViewController.scrollView.contentOffset
        }

        proxyDelegate.setContentOffset = {
            uiViewController.scrollView.contentOffset = $0
        }

        proxyDelegate.getContentSize = {
            uiViewController.scrollView.contentSize
        }

        proxyDelegate.getContentInset = {
            let contentInset = uiViewController.scrollView.contentInset
            return EdgeInsets(top: contentInset.top, leading: contentInset.left, bottom: contentInset.bottom, trailing: contentInset.right)
        }

        proxyDelegate.setContentInset = {
            uiViewController.scrollView.contentInset = UIEdgeInsets(top: $0.top, left: $0.leading, bottom: $0.bottom, right: $0.trailing)
        }

        proxyDelegate.getVisibleRect = {
            uiViewController.scrollView.bounds
        }

        context.coordinator.hostingController.rootView = content
    }

    class Coordinator: NSObject, UIScrollViewControllerDelegate {

        let hostingController: UIHostingController<Content>

        var parent: UIScrollViewWrapper

        init(parent: UIScrollViewWrapper) {
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
