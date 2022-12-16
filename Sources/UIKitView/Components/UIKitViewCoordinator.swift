import UIKit

/// Responsible for managing a UIKit view lifecycle and interfacing with SwiftUI.
public final class _UIKitViewCoordinator<UIViewType: UIView> {
    typealias Callback = _UIKitViewRepresenting<UIViewType>.Callback
    typealias LayoutContainer = _UIKitViewLayoutContainer<UIViewType>

    private(set) var layoutContainer: LayoutContainer?
    private let content: () -> UIViewType
    let onAppear: Callback?
    let onDisappear: Callback?

    init(content: @escaping @autoclosure () -> UIViewType,
         onAppear: Callback?,
         onDisappear: Callback?) {
        self.content = content
        self.onAppear = onAppear
        self.onDisappear = onDisappear
    }

    func makeLayoutContainer() -> LayoutContainer {
        guard let cached = layoutContainer else {
            let view = LayoutContainer(content())
            onAppear?(view.content)
            layoutContainer = view
            return view
        }
        return cached
    }
}
