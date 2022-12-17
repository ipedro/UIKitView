# UIKitView

## Documentation

https://ipedro.github.io/UIKitView/documentation/uikitview/

Sample usage:

```swift
var body: some View {
    ScrollView {
        VStack(spacing: 48) {
            UIKitView {
                UIButton(type: .roundedRect)
            } then: {
                $0.setTitle("I'm a Button", for: .normal)
                $0.backgroundColor = .systemTeal
                $0.setTitleColor(.white, for: .normal)
                $0.layer.cornerRadius = 12
            }
            .padding()
            
            UIKitView {
                let label = UILabel()
                label.numberOfLines = 0
                label.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
                return label
            }
            
            HStack {
                UIKitView {
                    UILabel()
                } then: {
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
                }
                UIKitView {
                    UILabel()
                } then: {
                    $0.numberOfLines = 0
                    $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
                }
            }
            
        }
        .padding()
    }
}
```
