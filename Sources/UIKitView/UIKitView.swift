import SwiftUI

// MARK: - UIKitView

/// Wraps a given UIKit view in a SwiftUI view.
///
/// If your view doesn't look as expected out-of-the box, play around with different layout proposals.
///
/// AutoLayout relies not only on setting constraints on your views, all views can be configured with have a [content compression resistance priority](https://developer.apple.com/documentation/uikit/uiview/1622465-contentcompressionresistanceprio) and a [content hugging priority](https://developer.apple.com/documentation/uikit/uiview/1622556-contenthuggingpriority) that determine how much it fights to retain its intrinsic content size when available space is less than
/// or greater than it needs, respectively. If your view isn't behaving as expected play around with them.
///
/// - Note: Size calculations are performed by calling [systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)](https://developer.apple.com/documentation/uikit/uiview/1622623-systemlayoutsizefitting)
///
/// - Parameters:
///   - layout: The preferred layout configuration.
///   - content: The view that you want to display in SwiftUI
///   - onAppear: An action to perform before this view is created.
///   - onStateChange: Called when the state of the specified view has new information from SwiftUI.
///   - onDisappear: An action that is performed Called before this view is dismantled.
///
/// - Returns: A UIKit view wrapped in an opaque SwiftUI view.
@ViewBuilder
public func UIKitView<V: UIView>(
    layout: UIKitViewProposedLayout = .compressedLayout(),
    content: @escaping () -> V,
    onAppear: _UIKitViewRepresenting<V>.Callback? = .none,
    onStateChange: _UIKitViewRepresenting<V>.Callback? = .none,
    onDisappear: _UIKitViewRepresenting<V>.Callback? = .none
) -> some View {
    if #available(iOS 16, *) {
        _UIKitViewRepresenting(
            content: content,
            layout: layout,
            onAppear: onAppear,
            onDisappear: onDisappear,
            onStateChange: onStateChange)
    } else {
        HorizontalGeometryReader { width in
            _UIKitViewRepresenting(
                content: content,
                layout: .init(
                    width: .init(width, .almostRequired)),
                onAppear: onAppear,
                onDisappear: onDisappear,
                onStateChange: onStateChange)
        }
    }
}
