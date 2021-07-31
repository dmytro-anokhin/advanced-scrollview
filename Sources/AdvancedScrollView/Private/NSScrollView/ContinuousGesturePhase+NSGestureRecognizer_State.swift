//
//  ContinuousGesturePhase+NSGestureRecognizer_State.swift
//  
//
//  Created by Dmytro Anokhin on 16/07/2021.
//

#if os(macOS)

import AppKit

extension ContinuousGesturePhase {

    init?(_ state: NSGestureRecognizer.State) {
        switch state {
            case .possible:
                self = .possible
            case .began:
                self = .began
            case .changed:
                self = .changed
            case .cancelled, .failed:
                self = .cancelled
            case .ended:
                self = .ended
            default:
                return nil
        }
    }
}

#endif
