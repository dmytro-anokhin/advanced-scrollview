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
        addGestureRecognizer(gestureRecognizer)

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

    // MARK: - Drag

    typealias PanGestureAction = (_ state: ContinuousGestureState, _ location: CGPoint, _ translation: CGPoint) -> Void

    func onPanGesture(perform action: PanGestureAction?) {
        if let action = action {
            setupPanGesture(perform: action)
        } else {
            resetPanGesture()
        }
    }

    @objc func handlePan(gestureRecognizer: NSPanGestureRecognizer) {
        guard let panGestureAction = panGestureAction else {
            return
        }

        // print("Handle pan: \(gestureRecognizer.state) translation: \(gestureRecognizer.translation(in: documentView))")

        guard let state = ContinuousGestureState(gestureRecognizer.state) else {
            assertionFailure("Unexpected pan gesture recognizer state: \(gestureRecognizer.state)")
            return
        }

        let location = gestureRecognizer.location(in: documentView)
        let translation = gestureRecognizer.translation(in: documentView)

        RunLoop.main.perform {
            panGestureAction(state, location, translation)
        }
    }

    private func setupPanGesture(perform action: @escaping PanGestureAction) {
        let selector = #selector(handlePan(gestureRecognizer:))
        let gestureRecognizer = NSPanGestureRecognizer(target: self, action: selector)
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)

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


fileprivate extension ContinuousGestureState {

    init?(_ state: NSGestureRecognizer.State) {
        switch state {
            case .began:
                self = .began
            case .changed:
                self = .changed
            case .cancelled:
                self = .cancelled
            case .ended:
                self = .ended
            default:
                return nil
        }
    }
}

#endif
