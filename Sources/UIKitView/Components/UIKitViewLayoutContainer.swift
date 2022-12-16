import UIKit

/// A container view that is able to calulate the size of its content
/// based on different layout proposals.
public final class _UIKitViewLayoutContainer<UIViewType: UIView>: UIView {
    let content: UIViewType

    private(set) var contentLayout: UIKitViewProposedLayout?

    private var contentSize = CGSize(
        width: UIView.noIntrinsicMetric,
        height: UIView.noIntrinsicMetric)

    init(_ content: UIViewType) {
        self.content = content
        super.init(frame: content.frame)
    
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        clipsToBounds = true
        addSubview(content)
    }

    public func setupConstraints() {
        [content.leadingAnchor.constraint(equalTo: leadingAnchor),
         content.topAnchor.constraint(equalTo: topAnchor),
         content.trailingAnchor.constraint(equalTo: trailingAnchor),
         content.bottomAnchor.constraint(equalTo: bottomAnchor)]
            .forEach {
                $0.priority = .almostRequired
                $0.isActive = true
            }
    }

    public override var intrinsicContentSize: CGSize { contentSize }

    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        contentLayout = .none
    }

    @discardableResult
    public func systemLayoutFittingSize(_ proposal: UIKitViewProposedLayout) -> CGSize {
        guard contentLayout != proposal else { return contentSize }
        
        let newValue = content.systemLayoutSizeFitting(
            proposal.size,
            withHorizontalFittingPriority: proposal.width.priority,
            verticalFittingPriority: proposal.height.priority)
        
        if newValue != self.contentSize,
           newValue.height != .infinity,
           newValue.width != .infinity {
            self.contentSize = newValue
            self.contentLayout = proposal
        }
        
        return newValue
    }
}
