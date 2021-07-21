# Advanced ScrollView

Advanced ScrollView creates a bridge between `UIScrollView` and `NSScrollView` and SwiftUI views.

What makes this scroll view "advanced"? You have full access to `UIScrollView` and `NSScrollView`  APIs. It is harder to use, but you can build all kinds of advanced interactions, like pinch to zoom at precise point, scroll with a given offset, infinite canvas, etc. 

```swift
import SwiftUI
import AdvancedScrollView


struct ScrollableImage: View {

    let image: Image

    var body: some View {
        AdvancedScrollView { _ in
            image
        }
    }
}
```

## Magnification

You can configure magnification behaviour using `Magnification` struct.

```swift
let magnification = Magnification(range: 1.0...4.0, initialValue: 1.0, isRelative: true)

AdvancedScrollView(magnification: magnification) { _ in
    image
}
```

`range` and `initialValue` allows to configure magnification range and initial magnification respectfully. `isRelative` defines if magnification must be calculated relative to the view's frame. I.e. content magnified to fit in the view.

## Proxy

Similarly to `ScrollView` and `ScrollViewReader` combination, `AdvancedScrollView` takes `ViewBuilder` closure with a single `AdvancedScrollViewProxy` argument that provides access to common properties and methods of the underlying scroll view.

The names are self-explanatory and while this documentation is in development please refer to `UIScrollView`/`NSScrollView` APIs.

```
func scrollTo(_ rect: CGRect, animated: Bool)

var contentOffset: CGPoint { get set }

var contentSize: CGSize { get }

var contentInset: EdgeInsets { get set }

var visibleRect: CGRect { get }

var scrollerInsets: EdgeInsets { get }

var magnification: CGFloat { get }

var isLiveMagnify: Bool { get }
```

## Events and Gestures

`AdvancedScrollView` won't alter event handling so in most cases you can expect SwiftUI gestures to work as is. But, underlying `NSScrollView`, when magnified, won't correctly translate points from its coordinate system to SwiftUI views. Good news is that `UIScrollView` correctly translates coordinates. 

As a solution to this problem `AdvancedScrollView` provides `onTapContentGesture` and `onDragContentGesture` gestures. This replicates `onTap` and `onDrag` view modifiers.

Downside is that this are event handlers are attached to the scroll view itself, so you need to determine which subview should handle an event. 

Benefit is that `onDragContentGesture` will manage state for you and even autoscroll content when needed.

If you're building iOS only app, not using magnification, or do not need to handle gestures at a specific location, using SwiftUI gestures with `AdvancedScrollView` should cover your case.

*If you happen to know how to make `NSScrollView` translate coordinates correctly, please reach out.*

