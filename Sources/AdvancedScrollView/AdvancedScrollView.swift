//
//  AdvancedScrollView.swift
//
//
//  Created by Dmytro Anokhin on 23/06/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
public struct AdvancedScrollView<Content: View>: View {

    public let magnification: Magnification

    public let isScrollIndicatorVisible: Bool

    let content: (_ proxy: AdvancedScrollViewProxy) -> Content

    public init(magnification: Magnification = Magnification(range: 1.0...4.0, initialValue: 1.0, isRelative: true),
                isScrollIndicatorVisible: Bool = true,
                @ViewBuilder content: @escaping (_ proxy: AdvancedScrollViewProxy) -> Content) {

        self.init(magnification: magnification,
                  isScrollIndicatorVisible: isScrollIndicatorVisible,
                  tapContentGestureInfo: nil,
                  dragContentGestureInfo: nil,
                  content: content)
    }

    init(magnification: Magnification = Magnification(range: 1.0...4.0, initialValue: 1.0, isRelative: true),
         isScrollIndicatorVisible: Bool = true,
         tapContentGestureInfo: TapContentGestureInfo?,
         dragContentGestureInfo: DragContentGestureInfo?,
         @ViewBuilder content: @escaping (_ proxy: AdvancedScrollViewProxy) -> Content) {
        self.magnification = magnification
        self.isScrollIndicatorVisible = isScrollIndicatorVisible
        self.tapContentGestureInfo = tapContentGestureInfo
        self.dragContentGestureInfo = dragContentGestureInfo
        self.content = content
    }

    public var body: some View {
        #if os(macOS)
        return NSScrollViewRepresentable(magnification: magnification,
                            hasScrollers: isScrollIndicatorVisible,
                            tapContentGestureInfo: tapContentGestureInfo,
                            dragContentGestureInfo: dragContentGestureInfo,
                            content: content)
        #else
        return UIScrollViewControllerRepresentable(magnification: magnification,
                            isScrollIndicatorVisible: isScrollIndicatorVisible,
                            tapContentGestureInfo: tapContentGestureInfo,
                            dragContentGestureInfo: dragContentGestureInfo,
                            content: content)
        #endif
    }

    var tapContentGestureInfo: TapContentGestureInfo?

    var dragContentGestureInfo: DragContentGestureInfo?
}
