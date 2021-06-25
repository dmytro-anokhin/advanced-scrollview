//
//  FitScrollView.swift
//  
//
//  Created by Dmytro Anokhin on 24/06/2021.
//

#if !os(macOS)

import UIKit
import SwiftUI


final class ScrollableContentView: UIView, UIScrollViewDelegate {

    let minimumZoomScale: CGFloat = 1.0

    let maximumZoomScale: CGFloat = 4.0

    let contentView: UIView

    private let scrollView: UIScrollView

    // TODO: Rename to clipping view
    private let documentView: UIView

    init(contentView: UIView) {
        self.contentView = contentView

        scrollView = UIScrollView(frame: .zero)
        documentView = UIView(frame: .zero)

        super.init(frame: .zero)

        documentView.clipsToBounds = true

        scrollView.backgroundColor = .lightGray
        documentView.backgroundColor = .darkGray

        documentView.addSubview(contentView)
        scrollView.addSubview(documentView)
        addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        scrollView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateLayout()
    }

    private func invalidateLayout() {
        guard contentSize.isPositive else {
            return
        }

        let ratio = min(scrollView.frame.width / contentSize.width,
                        scrollView.frame.height / contentSize.height)

        contentView.frame = CGRect(x: 0.0, y: 0.0, width: contentSize.width, height: contentSize.height)
        documentView.bounds = contentView.bounds

        scrollView.contentOffset = .zero

        resetZoomScale(minimumZoomScale)
        layoutScaledViews()
    }

    private func resetZoomScale(_ zoomScale: CGFloat) {
        let scrollViewSize = scrollView.frame.size
        let contentViewSize = contentView.frame.size

        guard scrollViewSize.isPositive && contentViewSize.isPositive else {
            return
        }

        let widthRatio = max(scrollViewSize.width / contentViewSize.width,
                             contentSize.width / scrollViewSize.width)

        let heightRatio = max(scrollViewSize.height / contentViewSize.height,
                             contentSize.height / scrollViewSize.height)

        scrollView.contentSize = contentViewSize

        scrollView.minimumZoomScale = 0.25
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 0.25

//        scrollView.minimumZoomScale = minimumZoomScale
//        scrollView.maximumZoomScale = max(max(widthRatio, heightRatio), maximumZoomScale)
//        scrollView.zoomScale = zoomScale;
    }

    private func layoutScaledViews() {
        let scrollViewSize = scrollView.frame.size
        let documentViewSize = documentView.frame.size

        var documentViewFrame = documentView.frame

        let size = CGSize(width: scrollViewSize.width - scrollView.contentInset.left - scrollView.contentInset.right,
                          height: scrollViewSize.height - scrollView.contentInset.top - scrollView.contentInset.bottom)

        documentViewFrame.origin.x = max((size.width - documentViewSize.width) * 0.5, 0.0)
        documentViewFrame.origin.y = max((size.height - documentViewSize.height) * 0.5, 0.0)

        documentView.frame = documentViewFrame
    }

    private var contentSize: CGSize {
        contentView.sizeThatFits(.greatestFiniteMagnitude)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        documentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        layoutScaledViews()
    }
}


final class FitScrollViewController: UIViewController {

    let contentViewController: UIViewController

    let minimumZoomScale: CGFloat

    let maximumZoomScale: CGFloat

    private(set) var zoomScale: CGFloat

    init(contentViewController: UIViewController, minimumZoomScale: CGFloat, maximumZoomScale: CGFloat, zoomScale: CGFloat) {
        self.contentViewController = contentViewController
        self.minimumZoomScale = minimumZoomScale
        self.maximumZoomScale = maximumZoomScale
        self.zoomScale = zoomScale

        super.init(nibName: nil, bundle: nil)
    }

    weak var delegate: UIScrollViewControllerDelegate?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {

//        scrollView.minimumZoomScale = minimumZoomScale
//        scrollView.maximumZoomScale = maximumZoomScale

        addChild(contentViewController)
        contentViewController.view.sizeToFit()

        let view = ScrollableContentView(contentView: contentViewController.view)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

//        NSLayoutConstraint.activate([
//            contentViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
//        ])

        contentViewController.didMove(toParent: self)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // scrollView.delegate = self
    }

    func zoom(_ zoomScale: CGFloat) {
        guard zoomScale != self.zoomScale else {
            return
        }

        self.zoomScale = zoomScale

        guard isViewLoaded else {
            return
        }

        scrollView.zoomScale = zoomScale
    }

    func scrollTo(_ rect: CGRect, animated: Bool) {
        guard isViewLoaded else {
            return
        }

        scrollView.scrollRectToVisible(rect, animated: animated)
    }

    // MARK: - Private

    private var scrollView: UIScrollView {
        view as! UIScrollView
    }
}


@available(iOS 13.0, *)
struct FitScrollViewWrapper<Content: View>: UIViewControllerRepresentable {

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

    func makeUIViewController(context: Context) -> FitScrollViewController {
        let scrollViewController = FitScrollViewController(contentViewController: context.coordinator.hostingController,
                                                          minimumZoomScale: zoomScaleRange.lowerBound,
                                                          maximumZoomScale: zoomScaleRange.upperBound,
                                                          zoomScale: zoomScale)
        // scrollViewController.delegate = context.coordinator

        return scrollViewController
    }

    func updateUIViewController(_ uiViewController: FitScrollViewController, context: Context) {
        proxyDelegate.scrollTo = { rect, animated in
            uiViewController.scrollTo(rect, animated: animated)
        }

        context.coordinator.hostingController.rootView = content
        uiViewController.zoom(zoomScale)
    }

    class Coordinator: NSObject {

        let hostingController: UIHostingController<Content>

        var parent: FitScrollViewWrapper

        init(parent: FitScrollViewWrapper) {
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


fileprivate extension CGSize {

    var isPositive: Bool {
        width > 0.0 && height > 0.0
    }
}

//final class FitScrollView: UIView, UIScrollViewDelegate {
//
//    let contentView: UIView
//
//    init(contentView: UIView) {
//        self.contentView = contentView
//        super.init(frame: .zero)
//
//        backgroundColor = .gray
//        scrollView.backgroundColor = .lightGray
//
//        addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        scrollView.delegate = self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        scrollView.frame = bounds
//        scrollView.contentSize = contentSize
//
//        let ratio = min(bounds.width / contentSize.width, bounds.height / contentSize.height)
//
//        contentView.frame = CGRect(x: (bounds.width - contentSize.width * ratio) * 0.5,
//                                   y: (bounds.height - contentSize.height * ratio) * 0.5,
//                                   width: contentSize.width,
//                                   height: contentSize.height)
//
//        scrollView.minimumZoomScale = ratio
//        scrollView.maximumZoomScale = 4.0
//        scrollView.zoomScale = ratio
//    }
//
//    // MARK: - Private
//
//    private let scrollView = UIScrollView()
//
//    private var contentSize: CGSize {
//        contentView.sizeThatFits(.greatestFiniteMagnitude)
//    }
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        contentView
//    }
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        let scrollViewSize = scrollView.frame.size
//        let contentViewSize = contentView.frame.size
//
//        var contentViewFrame = contentView.frame
//
//        let size = CGSize(width: scrollViewSize.width - scrollView.contentInset.left - scrollView.contentInset.right,
//                          height: scrollViewSize.height - scrollView.contentInset.top - scrollView.contentInset.bottom)
//
//        contentViewFrame.origin.x = max((size.width - contentViewSize.width) * 0.5, 0.0)
//        contentViewFrame.origin.y = max((size.height - contentViewSize.height) * 0.5, 0.0)
//
//        contentView.frame = contentViewFrame
//    }
//}


//final class FitScrollViewController: UIViewController {
//
//    let contentViewController: UIViewController
//
//    let minimumZoomScale: CGFloat
//
//    let maximumZoomScale: CGFloat
//
//    private(set) var zoomScale: CGFloat
//
//    init(contentViewController: UIViewController, minimumZoomScale: CGFloat, maximumZoomScale: CGFloat, zoomScale: CGFloat) {
//        self.contentViewController = contentViewController
//        self.minimumZoomScale = minimumZoomScale
//        self.maximumZoomScale = maximumZoomScale
//        self.zoomScale = zoomScale
//
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func loadView() {
//
//        addChild(contentViewController)
//        contentViewController.view.sizeToFit()
//
//        let scrollView = FitScrollView(contentView: contentViewController.view)
//
//        contentViewController.didMove(toParent: self)
//
//        self.view = scrollView
//    }
//
//}
//
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct FitScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
//
//    let zoomScaleRange: ClosedRange<CGFloat>
//
//    @Binding var zoomScale: CGFloat
//
//    let content: Content
//
//    let proxyDelegate: AdvancedScrollViewProxy.Delegate
//
//    init(zoomScaleRange: ClosedRange<CGFloat>, zoomScale: Binding<CGFloat>, proxyDelegate: AdvancedScrollViewProxy.Delegate, @ViewBuilder content: () -> Content) {
//        self.zoomScaleRange = zoomScaleRange
//        self._zoomScale = zoomScale
//        self.proxyDelegate = proxyDelegate
//        self.content = content()
//    }
//
//    func makeUIViewController(context: Context) -> FitScrollViewController {
//        let scrollViewController = FitScrollViewController(contentViewController: context.coordinator.hostingController,
//                                                          minimumZoomScale: zoomScaleRange.lowerBound,
//                                                          maximumZoomScale: zoomScaleRange.upperBound,
//                                                          zoomScale: zoomScale)
//        // scrollViewController.delegate = context.coordinator
//
//        return scrollViewController
//    }
//
//    func updateUIViewController(_ uiViewController: FitScrollViewController, context: Context) {
//        proxyDelegate.scrollTo = { rect, animated in
////            uiViewController.scrollTo(rect, animated: animated)
//        }
//
////        context.coordinator.hostingController.rootView = content
////        uiViewController.zoom(zoomScale)
//    }
//
//    class Coordinator: NSObject, UIScrollViewControllerDelegate {
//
//        let hostingController: UIHostingController<Content>
//
//        var parent: FitScrollViewWrapper
//
//        init(parent: FitScrollViewWrapper) {
//            self.hostingController = UIHostingController(rootView: parent.content)
//            self.parent = parent
//        }
//
//        func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat) {
//            parent.zoomScale = zoomScale
//        }
//
//        var contentSize: CGSize {
//            hostingController.sizeThatFits(in: .greatestFiniteMagnitude)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//}

#endif
