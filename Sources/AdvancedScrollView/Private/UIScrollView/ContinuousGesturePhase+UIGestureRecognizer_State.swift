//
//  ContinuousGesturePhase+UIGestureRecognizer_State.swift
//  
//
//  Created by Dmytro Anokhin on 17/07/2021.
//

#if !os(macOS)

import UIKit

extension ContinuousGesturePhase {

    init?(_ state: UIGestureRecognizer.State) {
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
