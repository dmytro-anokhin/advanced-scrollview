//
//  NSScrollViewSubclass.swift
//  
//
//  Created by Dmytro Anokhin on 13/07/2021.
//

#if os(macOS)

import AppKit
import Combine


@available(macOS 10.15, *)
final class NSScrollViewSubclass: NSScrollView, NSGestureRecognizerDelegate {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        NotificationCenter.default.publisher(for: NSScrollView.willStartLiveMagnifyNotification, object: self)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.isLiveMagnify = true
            }
            .store(in: &notificaitonsCancellables)

        NotificationCenter.default.publisher(for: NSScrollView.didEndLiveMagnifyNotification, object: self)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.isLiveMagnify = false
            }
            .store(in: &notificaitonsCancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) var isLiveMagnify: Bool = false

    // MARK: - Click

    typealias ClickGestureAction = (_ location: CGPoint) -> Void

    func onClickGesture(count: Int = 1, perform action: ClickGestureAction?) {
        if let action = action {
            setupClickGesture(count: count, perform: action)
        } else {
            resetClickGesture()
        }
    }

    @objc func handleClick(gestureRecognizer: NSClickGestureRecognizer) {
        guard let clickGestureAction = clickGestureAction else {
            return
        }

        let location = gestureRecognizer.location(in: documentView)
        clickGestureAction(location)
    }

    private func setupClickGesture(count: Int = 1, perform action: @escaping ClickGestureAction) {
        let selector = #selector(handleClick(gestureRecognizer:))
        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: selector)
        gestureRecognizer.numberOfClicksRequired = count
        gestureRecognizer.numberOfTouchesRequired = 1
        contentView.addGestureRecognizer(gestureRecognizer)

        clickGestureRecognizer = gestureRecognizer
        clickGestureAction = action
    }

    private func resetClickGesture() {
        if let clickGestureRecognizer = clickGestureRecognizer {
            removeGestureRecognizer(clickGestureRecognizer)
        }

        clickGestureRecognizer = nil
        clickGestureAction = nil
    }

    private weak var clickGestureRecognizer: NSClickGestureRecognizer?

    private var clickGestureAction: ClickGestureAction?

    // MARK: - Pan

    typealias PanGestureAction = (_ state: ContinuousGestureState, _ location: CGPoint, _ translation: CGPoint) -> Bool

    func onPanGesture(perform action: PanGestureAction?) {
        if let action = action {
            setupPanGesture(perform: action)
        } else {
            resetPanGesture()
        }
    }

    @objc func handlePan(gestureRecognizer: NSPanGestureRecognizer) {
        if isScrollFollowsPan {
            handlePanAndScrollFollows(gestureRecognizer: gestureRecognizer as! NSPanWithTranslationOffsetGestureRecognizer)
        } else {
            handleRegularPan(gestureRecognizer: gestureRecognizer)
        }
    }

    private var isScrollFollowsPan: Bool = false

    private func handlePanAndScrollFollows(gestureRecognizer: NSPanWithTranslationOffsetGestureRecognizer) {
        guard let panGestureAction = panGestureAction, let documentView = documentView else {
            return
        }

        guard let state = ContinuousGestureState(gestureRecognizer.state) else {
            assertionFailure("Unexpected pan gesture recognizer state: \(gestureRecognizer.state)")
            return
        }

        let visibleRect = documentVisibleRect
        let location: NSPoint = gestureRecognizer.location(in: documentView)
        var translation: NSPoint = gestureRecognizer.translation(in: documentView)
        var scrollTranslation: NSPoint = .zero

        // Top
        if location.y < visibleRect.minY {
            scrollTranslation.y = location.y - visibleRect.minY
        }

        // Left
        if location.x < visibleRect.minX {
            scrollTranslation.x = location.x - visibleRect.minX
        }

        // Bottom
        if location.y > visibleRect.maxY {
            scrollTranslation.y = location.y - visibleRect.maxY
        }

        // Right
        if location.x > visibleRect.maxX {
            scrollTranslation.x = location.x - visibleRect.maxX
        }

        if scrollTranslation != .zero {
            let contentOffset = contentView.bounds.origin
            var translatedContentOffset = contentOffset + scrollTranslation

            // Make sure we're not going out of bounds
            translatedContentOffset.x = min(max(0.0, translatedContentOffset.x), contentSize.width)
            translatedContentOffset.y = min(max(0.0, translatedContentOffset.y), contentSize.height)

            documentView.scroll(translatedContentOffset)

            gestureRecognizer.translationOffset = gestureRecognizer.translationOffset + scrollTranslation
            translation = gestureRecognizer.translation(in: documentView)
        }

        isScrollFollowsPan = panGestureAction(state, location, translation)
    }

    private func handleRegularPan(gestureRecognizer: NSPanGestureRecognizer) {
        guard let panGestureAction = panGestureAction, let documentView = documentView else {
            return
        }

        guard let state = ContinuousGestureState(gestureRecognizer.state) else {
            assertionFailure("Unexpected pan gesture recognizer state: \(gestureRecognizer.state)")
            return
        }

        let location = gestureRecognizer.location(in: documentView)
        let translation = gestureRecognizer.translation(in: documentView)

        isScrollFollowsPan = panGestureAction(state, location, translation)
    }

    private func setupPanGesture(perform action: @escaping PanGestureAction) {
        let selector = #selector(handlePan(gestureRecognizer:))
        let gestureRecognizer = NSPanWithTranslationOffsetGestureRecognizer(target: self, action: selector)
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.delegate = self
        contentView.addGestureRecognizer(gestureRecognizer)

        panGestureRecognizer = gestureRecognizer
        panGestureAction = action
    }

    private func resetPanGesture() {
        if let panGestureRecognizer = panGestureRecognizer {
            removeGestureRecognizer(panGestureRecognizer)
        }

        panGestureRecognizer = nil
        panGestureAction = nil
    }

    private weak var panGestureRecognizer: NSPanGestureRecognizer?

    private var panGestureAction: PanGestureAction?

    // MARK: - NSGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer, otherGestureRecognizer == clickGestureRecognizer {
            return true
        }

        return false
    }

    // MARK: - Private

    private var notificaitonsCancellables: Set<AnyCancellable> = []
}

#endif
