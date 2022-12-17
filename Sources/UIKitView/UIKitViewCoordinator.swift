import UIKit

/// Responsible for managing a UIKit view lifecycle and interfacing with SwiftUI.
public final class _UIKitViewCoordinator<UIViewType: UIView> {
    typealias LayoutContainer = _UIKitViewLayoutContainer<UIViewType>

    private(set) var layoutContainer: LayoutContainer?
    private let content: UIKitView<UIViewType>.Content
    let onStart: UIKitView<UIViewType>.Callback?
    let onFinish: UIKitView<UIViewType>.Callback?

    init(content: @escaping UIKitView<UIViewType>.Content,
         onStart: UIKitView<UIViewType>.Callback?,
         onFinish: UIKitView<UIViewType>.Callback?) {
        self.content = content
        self.onStart = onStart
        self.onFinish = onFinish
    }

    func makeUIView() -> LayoutContainer {
        guard let cached = layoutContainer else {
            let view = LayoutContainer(content())
            onStart?(view.content)
            layoutContainer = view
            return view
        }
        return cached
    }
    
    func finish() {
        guard let content = layoutContainer?.content else { return }
        onFinish?(content)
        layoutContainer = nil
    }
}
