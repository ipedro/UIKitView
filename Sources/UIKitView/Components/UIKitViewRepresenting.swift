import SwiftUI

public struct _UIKitViewRepresenting<UIViewType: UIView>: UIViewRepresentable {
    public typealias Callback = (UIViewType) -> Void

    var content: () -> UIViewType
    var layout: UIKitViewProposedLayout
    var onAppear: Callback?
    var onDisappear: Callback?
    var onStateChange: Callback?

    /// Creates the custom instance that you use to communicate changes from
    /// your view to other parts of your SwiftUI interface.
    public func makeCoordinator() -> _UIKitViewCoordinator<UIViewType> {
        _UIKitViewCoordinator(
            content: content(),
            onAppear: onAppear,
            onDisappear: onDisappear)
    }

    /// Creates the view object and configures its initial state.
    public func makeUIView(context: Context) -> _UIKitViewLayoutContainer<UIViewType> {
        context.coordinator.makeLayoutContainer()
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateUIView(_ container: _UIKitViewLayoutContainer<UIViewType>,
                             context: Context) {
        onStateChange?(container.content)
        context.coordinator.layoutContainer?.invalidateIntrinsicContentSize()
        context.coordinator.layoutContainer?.systemLayoutFittingSize(layout)
    }

    /// Cleans up the presented UIKit view (and coordinator) in anticipation of their removal.
    public static func dismantleUIView(_ container: _UIKitViewLayoutContainer<UIViewType>,
                                       coordinator: _UIKitViewCoordinator<UIViewType>) {
        coordinator.onDisappear?(container.content)
    }

    /// Returns the size of the composite view, given a proposed size and the view’s subviews.
    @available(iOS 16.0, *)
    public func sizeThatFits(_ size: ProposedViewSize,
                             uiView: _UIKitViewLayoutContainer<UIViewType>,
                             context: Context) -> CGSize? {
        let layout = UIKitViewProposedLayout(
            width: resolve(either: .init(size.width, .almostRequired), or: layout.width),
            height: resolve(either: .init(size.height, .fittingSizeLevel), or: layout.height))
        
        let sizeThatFits = uiView.systemLayoutFittingSize(layout)
        return sizeThatFits
    }

    private func resolve(either proposal: UIKitViewProposedLayout.Size?,
                         or original: UIKitViewProposedLayout.Size) -> UIKitViewProposedLayout.Size {
        // 10 is Apple's magic number in SwiftUI to keep "visible views" with unknown layout from "disappearing into a zero frame".
        guard let proposal = proposal, proposal.value != 10 else {
            // If we get this far we're better trusing our own layout settings.
            return original
        }
        return proposal
    }
}
