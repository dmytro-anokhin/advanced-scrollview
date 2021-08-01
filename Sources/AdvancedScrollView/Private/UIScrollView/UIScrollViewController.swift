//
//  UIScrollViewController.swift
//  
//
//  Created by Dmytro Anokhin on 24/06/2021.
//

#if !os(macOS)

import UIKit


protocol UIScrollViewControllerDelegate: NSObject {

    func scrollViewController(_ scrollViewController: UIScrollViewController, zoomScaleDidChange zoomScale: CGFloat)
}


final class UIScrollViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var contentViewController: UIViewController! {
        willSet {
            assert(contentViewController == nil, "This implementation expects content view controller to be set only once")
        }

        didSet {
            guard isViewLoaded else {
                return
            }

            attachContentViewController()
        }
    }

    let minimumZoomScale: CGFloat

    let maximumZoomScale: CGFloat

    private(set) var zoomScale: CGFloat

    let isZoomRelative: Bool

    let isScrollIndicatorVisible: Bool

    init(minimumZoomScale: CGFloat,
         maximumZoomScale: CGFloat,
         zoomScale: CGFloat,
         isZoomRelative: Bool,
         isScrollIndicatorVisible: Bool) {
        self.minimumZoomScale = minimumZoomScale
        self.maximumZoomScale = maximumZoomScale
        self.zoomScale = zoomScale
        self.isZoomRelative = isZoomRelative
        self.isScrollIndicatorVisible = isScrollIndicatorVisible

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
        scrollView.showsHorizontalScrollIndicator = isScrollIndicatorVisible
        scrollView.showsVerticalScrollIndicator = isScrollIndicatorVisible

        self.view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachContentViewController()
        scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.zoomToFit()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.zoomToFit()
        }
        completion: { _ in
        }
    }

    func scrollTo(_ rect: CGRect, animated: Bool) {
        guard isViewLoaded else {
            return
        }

        scrollView.scrollRectToVisible(rect, animated: animated)
    }

    var scrollView: UIScrollView {
        view as! UIScrollView
    }

    var contentView: UIView {
        contentViewController.view
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentViewController.view
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        zoomScale = scrollView.zoomScale / (zoomScaleMultiplier != 0.0 ? zoomScaleMultiplier : 1.0)
        updateConstraintsToMatchZoomScale()

        delegate?.scrollViewController(self, zoomScaleDidChange: zoomScale)
    }

    // MARK: - Tap

    typealias TapGestureAction = (_ location: CGPoint) -> Void

    func onTapGesture(count: Int = 1, perform action: TapGestureAction?) {
        if let action = action {
            setupTapGesture(count: count, perform: action)
        } else {
            resetTapGesture()
        }
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let tapGestureAction = tapGestureAction else {
            return
        }

        let location = gestureRecognizer.location(in: scrollView)
        tapGestureAction(location)
    }

    private func setupTapGesture(count: Int = 1, perform action: @escaping TapGestureAction) {
        let selector = #selector(handleTap(gestureRecognizer:))
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        gestureRecognizer.numberOfTapsRequired = count
        gestureRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(gestureRecognizer)

        tapGestureRecognizer = gestureRecognizer
        tapGestureAction = action
    }

    private func resetTapGesture() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            scrollView.removeGestureRecognizer(tapGestureRecognizer)
        }

        tapGestureRecognizer = nil
        tapGestureAction = nil
    }

    private weak var tapGestureRecognizer: UITapGestureRecognizer?

    private var tapGestureAction: TapGestureAction?

    // MARK: - Pan

    typealias PanGestureAction = (_ phase: ContinuousGesturePhase, _ location: CGPoint, _ translation: CGPoint) -> Bool

    func onPanGesture(perform action: PanGestureAction?) {
        if let action = action {
            setupPanGesture(perform: action)
        } else {
            resetPanGesture()
        }
    }

    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let panGestureAction = panGestureAction else {
            return
        }

        guard let phase = ContinuousGesturePhase(gestureRecognizer.state) else {
            assertionFailure("Unexpected pan gesture recognizer state: \(gestureRecognizer.state)")
            return
        }

        let location = gestureRecognizer.location(in: contentView)
        let translation = gestureRecognizer.translation(in: contentView)

        if !panGestureAction(phase, location, translation) {
            gestureRecognizer.isEnabled = false
            gestureRecognizer.isEnabled = true
        }
    }

    private func setupPanGesture(perform action: @escaping PanGestureAction) {
        let selector = #selector(handlePan(gestureRecognizer:))
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: selector)
        gestureRecognizer.minimumNumberOfTouches = 1
        gestureRecognizer.maximumNumberOfTouches = 1
        gestureRecognizer.delegate = self
        contentView.addGestureRecognizer(gestureRecognizer)

        panGestureRecognizer = gestureRecognizer
        panGestureAction = action

        scrollView.panGestureRecognizer.require(toFail: gestureRecognizer)
    }

    private func resetPanGesture() {
        if let panGestureRecognizer = panGestureRecognizer {
            contentView.removeGestureRecognizer(panGestureRecognizer)
        }

        panGestureRecognizer = nil
        panGestureAction = nil
    }

    private weak var panGestureRecognizer: UIPanGestureRecognizer?

    private var panGestureAction: PanGestureAction?

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer, let panGestureAction = panGestureAction {
            let location = gestureRecognizer.location(in: contentView)
            let translation = panGestureRecognizer!.translation(in: contentView)

            return panGestureAction(.possible, location, translation)
        }

        return true
    }

    // MARK: - Private

    private func attachContentViewController() {
        guard let contentViewController = contentViewController, contentViewController.parent == nil else {
            return
        }

        addChild(contentViewController)
        contentViewController.view.sizeToFit()

        scrollView.addSubview(contentViewController.view)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        topConstraint = contentViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor)
        leadingConstraint = contentViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        bottomConstraint = contentViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        trailingConstraint = contentViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)

        NSLayoutConstraint.activate([ topConstraint, leadingConstraint, bottomConstraint, trailingConstraint])

        contentViewController.didMove(toParent: self)
    }

    private var topConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    private func updateConstraintsToMatchZoomScale() {
        let contentViewSize = contentViewController.view.sizeThatFits(.greatestFiniteMagnitude)
        let scrollViewSize = scrollView.frame.size

        let horizontalOffset = max((scrollViewSize.width - scrollView.zoomScale * contentViewSize.width) * 0.5, 0.0)
        let verticalOffset = max((scrollViewSize.height - scrollView.zoomScale * contentViewSize.height) * 0.5, 0.0)

        topConstraint.constant = verticalOffset
        leadingConstraint.constant = horizontalOffset
        bottomConstraint.constant = verticalOffset
        trailingConstraint.constant = horizontalOffset

        view.layoutIfNeeded()
    }

    /// Multiplier used to calculate zoom scale relative to the frame
    private var zoomScaleMultiplier: CGFloat = 1.0

    private func zoomToFit() {
        guard isZoomRelative else {
            return
        }

        let contentViewSize = contentViewController.view.sizeThatFits(.greatestFiniteMagnitude)
        let scrollViewSize = scrollView.frame.size

        var newZoomScaleMultiplier = min(scrollViewSize.width / contentViewSize.width,
                                         scrollViewSize.height / contentViewSize.height)

        scrollView.minimumZoomScale = minimumZoomScale * newZoomScaleMultiplier
        scrollView.maximumZoomScale = maximumZoomScale * newZoomScaleMultiplier

        if zoomScaleMultiplier == newZoomScaleMultiplier { // Add a small delta to force update
            newZoomScaleMultiplier += 0.0001
        }

        zoomScaleMultiplier = newZoomScaleMultiplier
        scrollView.zoomScale = zoomScale * newZoomScaleMultiplier
    }
}

#endif
