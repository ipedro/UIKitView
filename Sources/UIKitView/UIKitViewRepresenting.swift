import SwiftUI

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

public struct _UIKitViewRepresenting<UIViewType: UIView>: UIViewRepresentable {
    public typealias Coordinator = _UIKitViewCoordinator<UIViewType>

    var layout: UIKitViewProposedLayout
    var content: UIKitView<UIViewType>.Content
    var onStart: UIKitView<UIViewType>.Callback?
    var onFinish: UIKitView<UIViewType>.Callback?
    var onStateChange: UIKitView<UIViewType>.Callback?

    /// Creates the custom instance that you use to communicate changes from
    /// your view to other parts of your SwiftUI interface.
    public func makeCoordinator() -> Coordinator {
        _UIKitViewCoordinator(
            content: content,
            onStart: onStart,
            onFinish: onFinish)
    }

    /// Creates the view object and configures its initial state.
    public func makeUIView(context: Context) -> _UIKitViewLayoutContainer<UIViewType> {
        context.coordinator.makeUIView()
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateUIView(_ container: _UIKitViewLayoutContainer<UIViewType>, context: Context) {
        onStateChange?(container.content)
        container.invalidateIntrinsicContentSize()
        container.systemLayoutFittingSize(layout)
    }

    /// Cleans up the presented UIKit view (and coordinator) in anticipation of their removal.
    public static func dismantleUIView(_ container: _UIKitViewLayoutContainer<UIViewType>,
                                       coordinator: Coordinator) {
        coordinator.finish()
    }

    /// Returns the size of the composite view, given a proposed size and the view’s subviews.
//    @available(iOS 16.0, *)
//    public func sizeThatFits(_ size: ProposedViewSize,
//                             uiView: _UIKitViewLayoutContainer<UIViewType>,
//                             context: Context) -> CGSize? {
//        let layout = UIKitViewProposedLayout(
//            width: resolve(either: (size.width, .highestSizeLevel), or: layout.width),
//            height: resolve(either: (size.height, .fittingSizeLevel), or: layout.height))
//
//        let sizeThatFits = uiView.systemLayoutFittingSize(layout)
//        return sizeThatFits
//    }

    private func resolve(either proposal: (CGFloat?, UILayoutPriority),
                         or original: UIKitViewProposedLayout.Size) -> UIKitViewProposedLayout.Size {
        // 10 is Apple's magic number in SwiftUI to keep "visible views" with unknown layout from "disappearing into a zero frame".
        guard let value = proposal.0, value != 10 else {
            // If we get this far we're better trusing our own layout settings.
            return original
        }
        return .init(value, priority: proposal.1)
    }
}
