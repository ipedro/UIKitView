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

import UIKit

extension UIKitView {
    /// A container view that is able to calulate the size of its content based on different layout proposals.
    final class LayoutContainerView: UIView {
        let view: UIViewType
        
        private(set) var layout: ProposedLayout?
        
        private var contentSize = CGSize(
            width: UIView.noIntrinsicMetric,
            height: UIView.noIntrinsicMetric)
        
        private lazy var layoutConstraints = [
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)]
        
        init(_ view: UIViewType) {
            self.view = view
            super.init(frame: view.frame)
            setupViews()
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            clipsToBounds = true
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            layoutConstraints.forEach {
                $0.isActive = true
            }
        }
        
        override var intrinsicContentSize: CGSize { contentSize }
        
        override func invalidateIntrinsicContentSize() {
            super.invalidateIntrinsicContentSize()
            layout = .none
        }
        
        override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
            view.contentCompressionResistancePriority(for: axis)
        }
        
        override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
            view.contentHuggingPriority(for: axis)
        }
        
        @discardableResult
        func systemLayoutFittingSize(_ proposal: ProposedLayout) -> CGSize {
            let newSize = view.systemLayoutSizeFitting(
                proposal.size,
                withHorizontalFittingPriority: proposal.width.priority,
                verticalFittingPriority: proposal.height.priority)
            
            if newSize != contentSize,
               newSize.height != .infinity,
               newSize.width != .infinity {
                contentSize = newSize
                layout = proposal
            }
            return newSize
        }
    }
}
