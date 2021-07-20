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

    var isAutoscrollEnabled: Bool {
        get {
            (documentView as? AutoscrollEnabledView)?.isAutoscrollEnabled ?? false
        }

        set {
            guard var autoscrollEnabledView = documentView as? AutoscrollEnabledView else {
                return
            }

            autoscrollEnabledView.isAutoscrollEnabled = newValue
        }
    }

    private var notificaitonsCancellables: Set<AnyCancellable> = []
}

@available(macOS 10.15, *)
final class NSClipViewSubclass: NSClipView {
}

protocol AutoscrollEnabledView {

    var isAutoscrollEnabled: Bool { get set }
}

@available(macOS 10.15, *)
final class NSHostingViewSubclass<Content: View>: NSHostingView<Content>, AutoscrollEnabledView {

    var isAutoscrollEnabled: Bool = false

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        if isAutoscrollEnabled {
            autoscroll(with: event)
        }
    }
}

#endif
