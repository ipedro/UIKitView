// MIT License
//
// Copyright (c) 2022 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

/// A view that displays a UIKit view object.
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
/// If you expect your view to be as big as possible in some direction, ``UIKitView/ProposedLayout/expanded(horizontalFit:verticalFit:)`` might be a better option. However if you need that a view is as small as possible horizontally, but grows vertically you could write the following:
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
/// ## If you're still having issues
///
/// If you have already tried sensible values for `traits` and `layout` and it still doesn't look as expected, don't panic. But you're view probably needs some auto layout improvements.
///
/// Please double check your constraints and try to lower some of their priorities to `defaultHigh` intead of `required`.
///
/// The system layout engine relies also in other relations between views such as [content compression resistance priority](https://developer.apple.com/documentation/uikit/uiview/1622465-contentcompressionresistanceprio) and [content hugging priority](https://developer.apple.com/documentation/uikit/uiview/1622556-contenthuggingpriority) – that determine how much it fights to retain its intrinsic content size when available space is less than or greater than it needs, respectively. Play around with them.
///
/// - Note: Size calculations are performed by calling [systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)](https://developer.apple.com/documentation/uikit/uiview/1622623-systemlayoutsizefitting)
public struct UIKitView<UIViewType: UIView>: View {
    /// Called after view events.
    public typealias Callback = (UIViewType) -> Void
    /// A UIKit view object builder.
    public typealias Content = () -> UIViewType
    
    var layout: ProposedLayout
    var content: Content
    var onStart: Callback?
    var onStateChange: Callback?
    var onFinish: Callback?
    
/// Creates a view that displays a UIKit view object.
/// - Parameters:
///   - traits: The characteriscs that will help define the strategy to calculate the view's size. Default is ``UIKitView/Traits/flexible()``
///   - layout: The type of box should de view fit into. Default is ``UIKitView/ProposedLayout/compressed(horizontalFit:verticalFit:)``
///   - content: The view object to be displayed in SwiftUI.
///   - onStart: (Optional) An action to perform right after the view is created. Executes only once per instance.
///   - onStateChange: (Optional) Called when the state of the specified view has new information from SwiftUI.
///   - onFinish: (Optional) An action that is performed before this view is dismantled.
///
/// - Returns: A UIKit view wrapped in an opaque SwiftUI view.
    public init(
        traits: Traits = .flexible(),
        size targetSize: TargetSize = .compressed(),
        content: @escaping Content,
        then onStart: Callback? = .none,
        onFinish: Callback? = .none,
        onStateChange: Callback? = .none
    ) {
        self.layout = .init(
            traits: traits,
            targetSize: targetSize)
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
                LayoutView(
                    layout: layout,
                    content: content,
                    onStart: onStart,
                    onFinish: onFinish,
                    onStateChange: onStateChange)
            } else {
                // On earlier OS versions we rely on a geometry reader
                // to read the container's width (and only the width).
                HorizontalGeometryReader { width in
                    LayoutView(
                        layout: .init(
                            traits: layout.traits,
                            targetSize: .init(
                                width: .init(width, priority: layout.traits.layoutPriority),
                                height: layout.targetSize.height)),
                        content: content,
                        onStart: onStart,
                        onFinish: onFinish,
                        onStateChange: onStateChange)
                }
            }
        }
        .fixedSize(
            horizontal: layout.traits.isHorizontalSizeFixed,
            vertical: layout.traits.isVerticalSizeFixed)
    }
}

struct UIKitView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .center) {
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
                    UISwitch()
                } then: {
                    $0.backgroundColor = .label.withAlphaComponent(0.1)
//                    $0.showsTouchWhenHighlighted = true
//                    $0.setTitle("I'm a button", for: .normal)
                }
//                .cornerRadius(12)
//                .padding(.vertical)
                
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
                        $0.contentMode = .scaleAspectFill
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
}
