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

    let zoomScaleRange: ClosedRange<CGFloat>

    @Binding var zoomScale: CGFloat

    let content: Content

    let proxyDelegate: AdvancedScrollViewProxy.Delegate

    init(zoomScaleRange: ClosedRange<CGFloat>, zoomScale: Binding<CGFloat>, proxyDelegate: AdvancedScrollViewProxy.Delegate, @ViewBuilder content: () -> Content) {
        self.zoomScaleRange = zoomScaleRange
        self._zoomScale = zoomScale
        self.proxyDelegate = proxyDelegate
        self.content = content()
    }

    func makeUIViewController(context: Context) -> UIScrollViewController {
        let scrollViewController = UIScrollViewController(contentViewController: context.coordinator.hostingController,
                                                          minimumZoomScale: zoomScaleRange.lowerBound,
                                                          maximumZoomScale: zoomScaleRange.upperBound,
                                                          zoomScale: zoomScale)
        scrollViewController.delegate = context.coordinator

        return scrollViewController
    }

    func updateUIViewController(_ uiViewController: UIScrollViewController, context: Context) {
        proxyDelegate.scrollTo = { rect, animated in
            uiViewController.scrollTo(rect, animated: animated)
        }

        context.coordinator.hostingController.rootView = content
        uiViewController.zoom(zoomScale)
    }

    class Coordinator: NSObject, UIScrollViewControllerDelegate {

        let hostingController: UIHostingController<Content>

        var parent: UIScrollViewWrapper

        init(parent: UIScrollViewWrapper) {
            self.hostingController = UIHostingController(rootView: parent.content)
            self.parent = parent
        }

        func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat) {
            parent.zoomScale = zoomScale
        }

        var contentSize: CGSize {
            hostingController.sizeThatFits(in: .greatestFiniteMagnitude)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}


#endif
