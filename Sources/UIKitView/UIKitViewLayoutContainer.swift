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

/// A container view that is able to calulate the size of its content
/// based on different layout proposals.
public final class _UIKitViewLayoutContainer<UIViewType: UIView>: UIView {
    let content: UIViewType

    private(set) var layout: UIKitViewProposedLayout?

    private var layoutSize = CGSize(
        width: UIView.noIntrinsicMetric,
        height: UIView.noIntrinsicMetric)
    init(_ content: UIViewType) {
        self.content = content
        super.init(frame: content.frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        addSubview(content)
    }

    public override var intrinsicContentSize: CGSize { layoutSize }

    public override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        content.contentHuggingPriority(for: axis)
    }
    
    public override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        content.contentCompressionResistancePriority(for: axis)
    }
    
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        layout = .none
    }

    @discardableResult
    public func systemLayoutFittingSize(_ proposal: UIKitViewProposedLayout) -> CGSize {
        if layout == proposal { return layoutSize }
        
        let newValue = content.systemLayoutSizeFitting(
            proposal.size,
            withHorizontalFittingPriority: proposal.width.priority,
            verticalFittingPriority: proposal.height.priority)
        
        if newValue != self.layoutSize,
           newValue.height != .infinity,
           newValue.width != .infinity {
            self.layoutSize = newValue
            self.layout = proposal
        }
        
        return newValue
    }
}
