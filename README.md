# Advanced ScrollView

Advanced ScrollView creates a bridge between `UIScrollView` and `NSScrollView` and SwiftUI views.

What makes this scroll view "advanced"? You have full access to `UIScrollView` and `NSScrollView`  APIs. It is harder to use, but you can build all kinds of advanced interactions, like pinch to zoom at precise point, scroll with a given offset, infinite canvas, etc. 

```swift
import SwiftUI
import AdvancedScrollView


struct ScrollableImage: View {

    let image: Image

    var body: some View {
        AdvancedScrollView(magnificationRange: 1.0...4.0) { _ in
            image
        }
    }
}
```
