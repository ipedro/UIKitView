# UIKitView

## Documentation

https://ipedro.github.io/UIKitView/documentation/uikitview/

Sample usage:

![Sample usage](./Docs/sample_usage.png)

```swift
var body: some View {
        ScrollView {
        VStack(spacing: 24) {
            UIKitView {
                UILabel()
            } then: {
                $0.adjustsFontForContentSizeCategory = true
                $0.numberOfLines = 0
                $0.attributedText = NSAttributedString(
                    string: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer",
                    attributes: [
                        .underlineStyle: NSNumber(value: 1),
                        .font: UIFont.preferredFont(forTextStyle: .headline),
                        .foregroundColor: UIColor.systemBackground,
                        .backgroundColor: UIColor.systemPink
                    ]
                )
            }
            .padding()
            .background(Color.primary.opacity(0.1))
            .cornerRadius(24)
            
            UIKitView {
                UIButton(type: .roundedRect)
            } then: {
                $0.backgroundColor = .label.withAlphaComponent(0.1)
                $0.showsTouchWhenHighlighted = true
                $0.setTitle("I'm a button", for: .normal)
            }
            .cornerRadius(12)
            .padding(.vertical)
            
            HStack(spacing: 24) {
                // Body Text
                Text("Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type.")
                
                // Should look and behave exactly the same
                UIKitView {
                    UILabel()
                } then: {
                    $0.font = .preferredFont(forTextStyle: .body)
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type."
                }
            }
            
            HStack(spacing: 24) {
                UIKitView {
                    UIImageView(image: .init(systemName: "checkmark"))
                } then: {
                    $0.contentMode = .scaleAspectFit
                }
                .padding()
                .background(Color.primary.opacity(0.1))
                
                // Should look exactly the same
                UIKitView {
                    UILabel()
                } then: {
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type."
                }
            }
        }
        .padding()
    }
}
```
