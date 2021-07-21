//
//  NSAutoscrollPanGestureRecognizer.swift
//  
//
//  Created by Dmytro Anokhin on 21/07/2021.
//

#if os(macOS)

import AppKit


/// `NSPanGestureRecognizer` subclass that keeps track of last mouse dragged event to use in `autoscroll(with:)` method.
final class NSAutoscrollPanGestureRecognizer: NSPanGestureRecognizer {

    private(set) var mouseDraggedEvent: NSEvent?

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        mouseDraggedEvent = event
    }

    /// Offset to add to translation.
    ///
    /// Offset it set to `.zero` whenever the gesture recognizer is reset.
    var translationOffset: NSPoint = .zero

    override func translation(in view: NSView?) -> NSPoint {
        super.translation(in: view) + translationOffset
    }

    /// Keeps track if some content was selected and autoscroll should happen.
    var isContentSelected: Bool = false

    override func reset() {
        super.reset()
        mouseDraggedEvent = nil
        translationOffset = .zero
        isContentSelected = false
    }
}

#endif

