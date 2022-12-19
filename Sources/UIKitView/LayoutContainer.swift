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

extension UIKitView {
    struct LayoutContainer: UIViewRepresentable {
        var layout: ProposedLayout
        var content: Content
        var onStart: Callback?
        var onFinish: Callback?
        var onStateChange: Callback?
        
        /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
        func makeCoordinator() -> Coordinator {
            Coordinator(onStart: onStart, onFinish: onFinish)
        }
        
        /// Creates the view object and configures its initial state.
        func makeUIView(context: Context) -> LayoutContainerView {
            context.coordinator.makeLayoutContainer(with: content)
        }
        
        /// Updates the state of the specified view with new information from SwiftUI.
        func updateUIView(_ layoutContainer: LayoutContainerView, context: Context) {
            onStateChange?(layoutContainer.view)
            layoutContainer.invalidateIntrinsicContentSize()
            layoutContainer.systemLayoutFittingSize(layout)
            layoutContainer.layoutIfNeeded()
        }
        
        /// Cleans up the presented UIKit view (and coordinator) in anticipation of their removal.
        static func dismantleUIView(_ container: LayoutContainerView, coordinator: Coordinator) {
            coordinator.finish()
        }
        
        /// Returns the size of the composite view, given a proposed size and the view’s subviews.
        @available(iOS 16.0, *)
        func sizeThatFits(_ size: ProposedViewSize, uiView layoutContainer: LayoutContainerView, context: Context) -> CGSize? {
            var proposal = layout
            proposal.width = resolve(
                either: .init(size.width, priority: proposal.systemLayoutPriority),
                or: proposal.width)
            proposal.height = resolve(
                either: .init(size.height, priority: proposal.systemLayoutPriority),
                or: proposal.height)
            
            let sizeThatFits = layoutContainer.systemLayoutFittingSize(proposal)
            
            return sizeThatFits
        }
        
        private func resolve(either proposal: LayoutFittingSize?, or original: LayoutFittingSize) -> LayoutFittingSize {
            // 10 is Apple's magic number in SwiftUI to keep "visible views" with unknown layout from "disappearing into a zero frame".
            guard let proposal = proposal, proposal.value != 10 else {
                // If we get this far we're better trusing our own layout settings.
                return original
            }
            return proposal
        }
    }
}
