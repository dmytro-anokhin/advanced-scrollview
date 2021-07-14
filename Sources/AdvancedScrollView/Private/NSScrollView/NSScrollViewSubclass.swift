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
final class NSScrollViewSubclass: NSScrollView {

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

    typealias ClickGestureAction = (_ location: CGPoint) -> Void

    func onClickGesture(count: Int = 1, perform action: ClickGestureAction?) {
        defer {
            clickGestureAction = action
        }

        if action == nil {
            guard let clickGestureRecognizer = clickGestureRecognizer else {
                return
            }

            removeGestureRecognizer(clickGestureRecognizer)
        }
        else {
            let selector = #selector(handleClick(gestureRecognizer:))
            let gestureRecognizer = NSClickGestureRecognizer(target: self, action: selector)
            gestureRecognizer.numberOfClicksRequired = count
            gestureRecognizer.numberOfTouchesRequired = 1

            addGestureRecognizer(gestureRecognizer)
            clickGestureRecognizer = gestureRecognizer
        }
    }

    @objc func handleClick(gestureRecognizer: NSClickGestureRecognizer) {
        guard let clickGestureAction = clickGestureAction else {
            return
        }

        let location = gestureRecognizer.location(in: documentView)
        clickGestureAction(location)
    }

    private var notificaitonsCancellables: Set<AnyCancellable> = []

    private weak var clickGestureRecognizer: NSClickGestureRecognizer?
    private var clickGestureAction: ClickGestureAction?
}

#endif
