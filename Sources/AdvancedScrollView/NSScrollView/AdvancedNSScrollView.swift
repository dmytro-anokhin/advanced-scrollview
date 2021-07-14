//
//  AdvancedNSScrollView.swift
//  
//
//  Created by Dmytro Anokhin on 13/07/2021.
//

#if os(macOS)

import AppKit
import Combine


@available(macOS 10.15, *)
final class AdvancedNSScrollView: NSScrollView {

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

    private var notificaitonsCancellables: Set<AnyCancellable> = []
}

#endif
