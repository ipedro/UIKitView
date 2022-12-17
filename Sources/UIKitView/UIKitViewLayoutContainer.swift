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
