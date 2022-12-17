import SwiftUI

/// A view that contains a UIKit view object.
///
/// ## Sizing Strategy
///
/// During the layout of the view hierarchy, each view proposes a size to each child view it contains. Normally the child view doesn’t need a fixed size so it accepts and conforms to the size offered by the parent.
///
/// You can also choose to fix the size of either axis at it's ideal size. This can result in the view exceeding the parent’s bounds, which may or may not be the effect you want. It's the equivalent of `SwiftUI.View.fixedSize(horizontal:vertical:)`.
///
/// Is your view still isn't behaving as expected?
///
/// ## Layout Proposal
///
/// If your view doesn't look as expected out-of-the box, try changing layout priorities and the target sizes.
///
/// If you expect your view to be as big as possible in some direction, ``UIKitViewProposedLayout/expanded(horizontalFit:verticalFit:)`` might be a better option. However if you need that a view is as small as possible horizontally, but grows vertically you could write the following:
///
/// ```swift
/// UIKitViewProposedLayout(
///     width: .compressedSize(),
///     height: .expandedSize())
/// ```
///
/// or
///
/// ```swift
/// UIKitViewProposedLayout(
///     width: .compressedSize(priority: .defaultHigh),
///     height: .expandedSize())
/// ```
///
/// And if even this doesn't solve it, don't worry.
///
/// ## Let's fix your view
///
/// Auto Layout relies not only on layout constraints, but also in other relations such as [content compression resistance priority](https://developer.apple.com/documentation/uikit/uiview/1622465-contentcompressionresistanceprio) and [content hugging priority](https://developer.apple.com/documentation/uikit/uiview/1622556-contenthuggingpriority) – that determine how much it fights to retain its intrinsic content size when available space is less than or greater than it needs, respectively. Play around with them.
///
/// - Note: Size calculations are performed by calling [systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)](https://developer.apple.com/documentation/uikit/uiview/1622623-systemlayoutsizefitting)
public struct UIKitView<V: UIView>: View {
    /// A closure that is called after a view lifecycle event
    public typealias Callback = (V) -> Void
    public typealias Content = () -> V
    
    var sizing: UIKitViewSizingStrategy
    var layout: UIKitViewProposedLayout
    var content: Content
    var onStart: Callback?
    var onStateChange: Callback?
    var onFinish: Callback?
    
/// Creates a view that contains a UIKit view object.
/// - Parameters:
///   - layout: The type of box should de view fit into. Default is ``UIKitViewProposedLayout/compressed(horizontalFit:verticalFit:)``
///   - sizing: Defines the view sizing strategy. Default is ``UIKitViewSizingStrategy/flexible()``
///   - content: The view object to be displayed in SwiftUI.
///   - onStart: (Optional) An action to perform right after the view is created. Executes only once per instance.
///   - onStateChange: (Optional) Called when the state of the specified view has new information from SwiftUI.
///   - onFinish: (Optional) An action that is performed before this view is dismantled.
///
/// - Returns: A UIKit view wrapped in an opaque SwiftUI view.
    public init(
        sizing: UIKitViewSizingStrategy = .flexible(),
        layout: UIKitViewProposedLayout = .compressed(),
        content: @escaping Content,
        then onStart: Callback? = .none,
        onFinish: Callback? = .none,
        onStateChange: Callback? = .none
    ) {
        self.sizing = sizing
        self.layout = layout
        self.content = content
        self.onStart = onStart
        self.onStateChange = onStateChange
        self.onFinish = onFinish
    }
    
    public var body: some View {
        Group {
            // We rely on `sizeThatFits(_:uiView:context:)` that was introduced in iOS 16
            // https://developer.apple.com/documentation/swiftui/uiviewrepresentable/sizethatfits(_:uiview:context:)-9ojeu
            if #available(iOS 16, *) {
                _UIKitViewRepresenting(
                    layout: layout,
                    content: content,
                    onStart: onStart,
                    onFinish: onFinish,
                    onStateChange: onStateChange)
            } else {
                // On earlier OS versions we rely on a geometry reader
                // to read the container'shorizontal axis
                HorizontalGeometryReader { width in
                    _UIKitViewRepresenting(
                        layout: .init(
                            width: .init(width, priority: .highestSizeLevel)),
                        content: content,
                        onStart: onStart,
                        onFinish: onFinish,
                        onStateChange: onStateChange)
                }
            }
        }
        .fixedSize(
            horizontal: sizing.isHorizontalSizeFixed,
            vertical: sizing.isVerticalSizeFixed)
    }
}

struct UIKitView_Previews: PreviewProvider {
    static var previews: some View {
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
}
