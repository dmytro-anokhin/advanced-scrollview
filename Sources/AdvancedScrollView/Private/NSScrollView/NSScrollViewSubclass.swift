//
//  NSScrollViewSubclass.swift
//  
//
//  Created by Dmytro Anokhin on 13/07/2021.
//

#if os(macOS)

import AppKit
import SwiftUI
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

    var isAutoscrollEnabled: Bool = true

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

    typealias PanGestureAction = (_ phase: ContinuousGesturePhase, _ location: CGPoint, _ translation: CGPoint) -> Bool

    func onPanGesture(perform action: PanGestureAction?) {
        if let action = action {
            setupPanGesture(perform: action)
        } else {
            resetPanGesture()
        }
    }

    @objc func handlePan(gestureRecognizer: NSAutoscrollPanGestureRecognizer, event: Any) {
        guard let panGestureAction = panGestureAction, let documentView = documentView else {
            return
        }

        guard let phase = ContinuousGesturePhase(gestureRecognizer.state) else {
            assertionFailure("Unexpected pan gesture recognizer state: \(gestureRecognizer.state)")
            return
        }

        if isAutoscrollEnabled {
            let visibleRect = documentVisibleRect

            if gestureRecognizer.isContentSelected,
               phase == .changed,
               let event = gestureRecognizer.mouseDraggedEvent {

                documentView.autoscroll(with: event)
                gestureRecognizer.translationOffset = gestureRecognizer.translationOffset + documentVisibleRect.origin - visibleRect.origin
            }
        }

        let location = gestureRecognizer.location(in: documentView)
        let translation = gestureRecognizer.translation(in: documentView)

        gestureRecognizer.isContentSelected = panGestureAction(phase, location, translation)
    }

    private func setupPanGesture(perform action: @escaping PanGestureAction) {
        let selector = #selector(handlePan(gestureRecognizer:event:))
        let gestureRecognizer = NSAutoscrollPanGestureRecognizer(target: self, action: selector)
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

    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        guard gestureRecognizer == panGestureRecognizer,
           let panGestureAction = panGestureAction,
           let documentView = documentView else {
            return true
        }

        let location = gestureRecognizer.location(in: documentView)
        let translation = (gestureRecognizer as! NSPanGestureRecognizer).translation(in: documentView)

        return panGestureAction(.possible, location, translation)
    }

    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer, otherGestureRecognizer == clickGestureRecognizer {
            return true
        }

        return false
    }

    // MARK: - Private

    private var notificaitonsCancellables: Set<AnyCancellable> = []
}

@available(macOS 10.15, *)
final class NSClipViewSubclass: NSClipView {
}

@available(macOS 10.15, *)
final class NSHostingViewSubclass<Content: View>: NSHostingView<Content> {
}

#endif
