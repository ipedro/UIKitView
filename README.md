# UIKitView

Sample usage:

```swift
  // abbreviated declaration
  UIKitView {
      UILabel()
  }

  // complete declaration
  UIKitView(layout: .compressedLayout()) {
      UIButton()
  } onAppear: { button in
      button.backgroundColor = .red
  } onStateChange: { button in
      // react to state changes
  } onDisappear: { button in
      // called when view is deinitialized
  }
```
