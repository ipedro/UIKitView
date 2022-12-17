import SwiftUI

/// A view that contains a UIKit view object.
///
/// ## Sizing Strategy
///
/// During the layout of the view hierarchy, each view proposes a size to each child view it contains. Normally the child view doesn’t need a fixed size so it accepts and conforms to the size offered by the parent.
///
/// You can also choose to fix the size of either axis at it's ideal size. This can result in the view exceeding the parent’s bounds, which may or may not be the effect you want. It's the equivalent of `.fixedSize(horizontal:vertical:)`.
///
/// Is your view still isn't behaving as expected?
///
/// ## Layout Proposal
///
/// If your view doesn't look as expected out-of-the box, try changing layout priorities and the target sizes.
///
/// If you expect your view to be as big as possible in some direction, ``UIKitViewProposedLayout/expandedLayout(horizontalFit:verticalFit:)`` might be a better option. However if you need that a view is as small as possible horizontally, but grows vertically you could write the following:
///
/// ```swift
/// UIKitViewProposedLayout(
///     width: .compressedSize(),
///     height: .expandedSize())
/// ```
///
/// Still here? Then let's talk about
///
/// ## Let's fix your view
///
/// Auto Layout relies not only on layout constraints, but also in other relations such as [content compression resistance priority](https://developer.apple.com/documentation/uikit/uiview/1622465-contentcompressionresistanceprio) and [content hugging priority](https://developer.apple.com/documentation/uikit/uiview/1622556-contenthuggingpriority) – that determine how much it fights to retain its intrinsic content size when available space is less than or greater than it needs, respectively. Play around with them.
///
/// - Note: Size calculations are performed by calling [systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)](https://developer.apple.com/documentation/uikit/uiview/1622623-systemlayoutsizefitting)
///
/// - Parameters:
///   - layout: The type of box should de view fit into. Default is ``UIKitViewProposedLayout/compressed(horizontalFit:verticalFit:)``
///   - sizing: Defines the view sizing strategy. Default is ``UIKitViewSizingStrategy/flexible()``
///   - content: The view object to be displayed in SwiftUI.
///   - onAppear: (Optional) An action to perform before this view is created.
///   - onStateChange: (Optional) Called when the state of the specified view has new information from SwiftUI.
///   - onDisappear: (Optional) An action that is performed before this view is dismantled.
///
/// - Returns: A UIKit view wrapped in an opaque SwiftUI view.
@ViewBuilder
public func UIKitView<UIViewType: UIView>(
    sizing: UIKitViewSizingStrategy = .flexible(),
    layout: UIKitViewProposedLayout = .compressed(),
    content: @escaping () -> UIViewType,
    onAppear: _UIKitViewRepresenting<UIViewType>.Callback? = .none,
    onStateChange: _UIKitViewRepresenting<UIViewType>.Callback? = .none,
    onDisappear: _UIKitViewRepresenting<UIViewType>.Callback? = .none
) -> some View {
    Group {
        if #available(iOS 16, *) {
            _UIKitViewRepresenting(
                layout: layout,
                content: content,
                onAppear: onAppear,
                onDisappear: onDisappear,
                onStateChange: onStateChange)
        } else {
            HorizontalGeometryReader { width in
                _UIKitViewRepresenting(
                    layout: .init(
                        width: .init(
                            width,
                            priority: .compressedSizeLevel)),
                    content: content,
                    onAppear: onAppear,
                    onDisappear: onDisappear,
                    onStateChange: onStateChange)
            }
        }
    }
    .fixedSize(
        horizontal: sizing.isHorizontalSizeFixed,
        vertical: sizing.isVerticalSizeFixed)
}

struct UIKitView_Previews: PreviewProvider {
    static var previews: some View {
        UIKitView {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .title1)
            label.text = "Hello World"
            return label
        }
        
        UIKitView {
            UILabel()
        } onAppear: {
            $0.font = .preferredFont(forTextStyle: .title1)
            $0.text = "Hello Again"
        }
        
        UIKitView {
            UIButton(type: .roundedRect)
        } onAppear: {
            $0.setTitle("I'm a Button", for: .normal)
        }
    }
}
