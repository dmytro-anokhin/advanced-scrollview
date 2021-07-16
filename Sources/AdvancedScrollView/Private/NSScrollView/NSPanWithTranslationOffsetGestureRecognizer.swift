//
//  NSPanWithTranslationOffsetGestureRecognizer.swift
//  
//
//  Created by Dmytro Anokhin on 16/07/2021.
//

#if os(macOS)

import AppKit


/// `NSPanGestureRecognizer` subclass that adds offset to its translation.
final class NSPanWithTranslationOffsetGestureRecognizer: NSPanGestureRecognizer {

    /// Offset to add to translation.
    ///
    /// Offset it set to `.zero` whenever the gesture recognizer is reset.
    var translationOffset: NSPoint = .zero

    override func translation(in view: NSView?) -> NSPoint {
        super.translation(in: view) + translationOffset
    }

    override func reset() {
        super.reset()
        translationOffset = .zero
    }
}

#endif
