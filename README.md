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

`AdvancedScrollView` takes `ViewBuilder` closure and will automatically scroll content it returns. Additionally you can configure magnification behaviour using `Magnification` struct. `AdvancedScrollViewProxy` object provides access to common properties and methods of underlying `UIScrollView`/`NSScrollView`.

```swift
AdvancedScrollView(magnification: Magnification(range: 1.0...4.0, initialValue: 1.0, isRelative: false)) { proxy in
    image
        .onTapGesture {
            print(proxy.visibleRect)
        }
}
```

Documentation is in development, names of properties and merthods are self-explanatory, and follow such of `UIScrollView`/`NSScrollView`.
