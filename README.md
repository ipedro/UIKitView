# UIKitView

## Documentation

https://ipedro.github.io/UIKitView/documentation/uikitview/

Sample usage:

```swift
var body: some View {
    ScrollView {
        VStack {
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
                        .foregroundColor: UIColor.systemBackground
                    ]
                )
            }
            .padding()
            .background(Color.accentColor)
            .cornerRadius(16)
            
            UIKitView {
                UIButton(type: .roundedRect)
            } then: {
                $0.setTitle("I'm a button", for: .normal)
            }
            .padding(.vertical)
            
            HStack {
                // Medium Body Regular Text
                Text("Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type.")
                    .padding()
                
                // Should look exactly the same
                UIKitView {
                    UILabel()
                } then: {
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type."
                }
                .padding()
            }
            
            HStack {
                UIKitView {
                    UIImageView(image: .init(systemName: "checkmark.seal.fill"))
                }
                .aspectRatio(contentMode: .fit)
                
                // Should look exactly the same
                UIKitView {
                    UILabel()
                } then: {
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type."
                }
                .padding()
            }
        }
        .padding()
    }
}
```
