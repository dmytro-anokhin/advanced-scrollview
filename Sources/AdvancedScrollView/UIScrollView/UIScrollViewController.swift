//
//  UIScrollViewController.swift
//  
//
//  Created by Dmytro Anokhin on 24/06/2021.
//

#if !os(macOS)

import UIKit
import SwiftUI


protocol UIScrollViewControllerDelegate: NSObject {

    func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat)
}


final class UIScrollViewController: UIViewController, UIScrollViewDelegate {

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
        let scrollView = UIScrollView(frame: .zero)
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        addChild(contentViewController)
        contentViewController.view.sizeToFit()

        scrollView.addSubview(contentViewController.view)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])

        contentViewController.didMove(toParent: self)

        self.view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
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

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentViewController.view
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        zoomScale = scrollView.zoomScale
        delegate?.scrollViewController(self, zoomScaleDidChange: zoomScale)
    }

    // MARK: - Private

    private var scrollView: UIScrollView {
        view as! UIScrollView
    }
}


extension CGSize {

    static var greatestFiniteMagnitude: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}


#endif

