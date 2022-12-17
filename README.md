# UIKitView

## Documentation

https://ipedro.github.io/UIKitView/documentation/uikitview/

Sample usage:

```swift
  // abbreviated declaration
  UIKitView {
      UILabel()
  }

  // complete declaration
  UIKitView(layout: .compressedLayout()) {
      UILabel()
  } onAppear: { label in
      label.text = "my text"
      label.textColor = .systemRed
  } onStateChange: { label in
      // react to state changes
  } onDisappear: { label in
      // called when view is deinitialized
  }
```
