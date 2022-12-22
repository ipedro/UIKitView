import SwiftUI

/** A view that displays a UIKit view object.

 ## Code Examples

 ```swift
     UIKitView {
         UILabel()
     } onChange: {
         // this closure gets called the first time the view is drawn
         // and then whenever view state is updated.
         $0.adjustsFontForContentSizeCategory = true
         $0.numberOfLines = 0
         $0.text = "Lorem Ipsum dolor sit amet."
     }
 ```
 
 Reacting to state updates
 
 ```swift
 struct MyView: View {
     @Binding var myIcon: UIImage?
     
     var body: some View {
         UIKitView {
             UIImageView()
         } onChange: {
             $0.image = myIcon // gets called whenever `myIcon` is updated
         }
     }
 }
 ```

 ## Layout

 If your view doesn't look as expected out-of-the box, try changing layout priorities and the target sizes.

 If you expect your view to be as big as possible in some direction, ``UIKitView/ProposedLayout/expanded(horizontalFit:verticalFit:)`` might be a better option.
 
 ## Sizing

 During the layout of the view hierarchy, each view proposes a size to each child view it contains. Normally the child view doesn’t need a fixed size so it accepts and conforms to the size offered by the parent.

 You can also choose to fix the size of either axis at it's ideal size. This can result in the view exceeding the parent’s bounds. If this seems like the effect you want, try adding  [`fixedSize()`](https://developer.apple.com/documentation/swiftui/view/fixedsize()) or the [`fixedSize(horizontal:vertical:)`](https://developer.apple.com/documentation/swiftui/view/fixedsize(horizontal:vertical:)) modifiers to your view.

 Is your view still isn't behaving as expected?
 
 ## If you're still having issues

 If you have already tried sensible values for `layout` and it still doesn't look as expected, don't panic. But you're view probably needs some auto layout improvements.

 Please double check your constraints and try to lower some of their priorities to `defaultHigh` intead of `required`.

 The system layout engine relies also in other relations between views such as [content compression resistance priority](https://developer.apple.com/documentation/uikit/uiview/1622465-contentcompressionresistanceprio) and [content hugging priority](https://developer.apple.com/documentation/uikit/uiview/1622556-contenthuggingpriority) – that determine how much it fights to retain its intrinsic content size when available space is less than or greater than it needs, respectively. Play around with them.

 - Note: Size calculations are performed by calling [systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)](https://developer.apple.com/documentation/uikit/uiview/1622623-systemlayoutsizefitting)
 **/
public struct UIKitView<UIViewType: UIView>: View {
    /// Closure that returns the view as argument.
    public typealias Callback = (UIViewType) -> Void
    /// Closure that returns the view and the current context as arguments.
    public typealias ContextCallback = (UIViewType, _LayoutContainer.Context) -> Void
    /// A UIKit view object builder.
    public typealias Content = () -> UIViewType
    
    var layout: ProposedLayout
    var content: Content
    var onChange: ContextCallback?
    var onFinish: Callback?
    
    // MARK: - Inits
    
    /**
     Creates a view with a callback that returns the view itself as argument on state changes.
     
     When the state of your app changes, SwiftUI updates the portions of your
     interface affected by those changes. SwiftUI calls this method for any
     changes affecting the corresponding UIKit view. Use the `then:` parameter to inject configuration
     updates to your view to match the new state information.
     
     - Parameters:
     - layout: The type of box should de view fit into. Default is    ``UIKitView/ProposedLayout/compressed(horizontalFit:verticalFit:)``
     - content: The view object to be displayed in SwiftUI.
     - onChange: (Optional) Updates the state of the specified view with new information from SwiftUI with the view as a parameter.
     - onFinish: (Optional) An action that is performed before this view is dismantled.
     
     - Returns: A UIKit view wrapped in an opaque SwiftUI view.
     */
    public init(
        layout: ProposedLayout = .compressed(),
        content: @escaping Content,
        onChange: @escaping (UIViewType) -> Void,
        onFinish: Callback? = .none
    ) {
        self.layout = layout
        self.content = content
        self.onFinish = onFinish
        self.onChange = { view, _ in
            onChange(view) // ignore context
        }
    }
    
    /**
     Creates a view with a callback that returns the view itself and the [context](https://developer.apple.com/documentation/swiftui/uiviewrepresentablecontext) as arguments on state changes.
     
     When the state of your app changes, SwiftUI updates the portions of your
     interface affected by those changes. SwiftUI calls this method for any
     changes affecting the corresponding UIKit view. Use the `then:` parameter to inject configuration
     updates to your view to match the new state information provided in the `context` argument.
     
     - Parameters:
     - layout: The type of box should de view fit into. Default is    ``UIKitView/ProposedLayout/compressed(horizontalFit:verticalFit:)``
     - content: The view object to be displayed in SwiftUI.
     - onChange: (Optional) Updates the state of the specified view with new information from SwiftUI with the context and the view as parameters.
     - onFinish: (Optional) An action that is performed before this view is dismantled.
     
     - Returns: A UIKit view wrapped in an opaque SwiftUI view.
     */
    public init(
        layout: ProposedLayout = .compressed(),
        content: @escaping Content,
        onChange: ContextCallback? = .none,
        onFinish: Callback? = .none
    ) {
        self.layout = layout
        self.content = content
        self.onChange = onChange
        self.onFinish = onFinish
    }
    
    // MARK: - Body
    
    public var body: some View {
        // We rely on `sizeThatFits(_:uiView:context:)` that was introduced in iOS 16
        // https://developer.apple.com/documentation/swiftui/uiviewrepresentable/sizethatfits(_:uiview:context:)-9ojeu
        if #available(iOS 16, *) {
            _LayoutContainer(
                layout: layout,
                content: content,
                onChange: onChange,
                onFinish: onFinish)
        } else {
            // On earlier OS versions we rely on a geometry reader
            // to read the container's width (and only the width).
            HorizontalGeometryReader { width in
                _LayoutContainer(
                    layout: .init(
                        width: resolve(width: width, with: layout),
                        height: layout.height,
                        systemLayoutPriority: layout.systemLayoutPriority),
                    content: content,
                    onChange: onChange,
                    onFinish: onFinish)
            }
        }
    }
    
    private func resolve(width: CGFloat, with layout: ProposedLayout) -> LayoutFittingSize {
        width > .zero ? .init(width, priority: layout.systemLayoutPriority) : layout.width
    }
    
    // MARK: - ProposedLayout

    /// Contains layout information for a view object.
    public struct ProposedLayout: Equatable {
        /// The priority given to system layout suggestions. To customize globally set `UILayoutPriority.uiKitViewDefault` to whatever priority makes sense for your use case.
        var systemLayoutPriority: UILayoutPriority = .uiKitViewDefault
        var width: LayoutFittingSize
        var height: LayoutFittingSize
        
        /// Creates a layout proposal for a view object.
        public init(width: LayoutFittingSize,
                    height: LayoutFittingSize) {
            self.width = width
            self.height = height
        }
        
        /// Creates a layout proposal for a view object.
        public init(width: LayoutFittingSize,
                    height: LayoutFittingSize,
                    systemLayoutPriority: UILayoutPriority) {
            self.width = width
            self.height = height
            self.systemLayoutPriority = systemLayoutPriority
        }
        
        /// Creates a layout proposal for a view object.
        public init(size: CGSize,
                    horizontalFit: UILayoutPriority = .fittingSizeLevel,
                    verticalFit: UILayoutPriority = .fittingSizeLevel) {
            width = .init(size.width, priority: horizontalFit)
            height = .init(size.height, priority: verticalFit)
        }
        
        var size: CGSize {
            .init(width: width.value, height: height.value)
        }
        
        /// The narrowest and shortest size. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingCompressedSize)`.
        ///
        /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
        ///
        /// - Parameter priority: The priority for constraints. Specify `.fittingSizeLevel` to get a size that is as close as possible to the target size.
        public static func compressed(
            horizontalFit: UILayoutPriority = .fittingSizeLevel,
            verticalFit: UILayoutPriority = .fittingSizeLevel
        ) -> Self {
            .init(
                size: UIView.layoutFittingCompressedSize,
                horizontalFit: horizontalFit,
                verticalFit: verticalFit)
        }
        
        /// The wide and tall as possible. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingExpandedSize)`.
        
        /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func expanded(
            horizontalFit: UILayoutPriority = .fittingSizeLevel,
            verticalFit: UILayoutPriority = .fittingSizeLevel
        ) -> Self {
            .init(
                size: UIView.layoutFittingExpandedSize,
                horizontalFit: horizontalFit,
                verticalFit: verticalFit)
        }
        
        /// The same size as the device's main screen. Equivalent to `UIScreen.main.bounds.size`.
        
        /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func device(
            horizontalFit: UILayoutPriority = .fittingSizeLevel,
            verticalFit: UILayoutPriority = .fittingSizeLevel
        ) -> Self {
            .init(
                size: UIScreen.main.bounds.size,
                horizontalFit: horizontalFit,
                verticalFit: verticalFit)
        }
    }
    
    // MARK: - LayoutFittingSize

    /// A value with a particular priority.
    public struct LayoutFittingSize: Equatable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
        public var value: CGFloat
        public var priority: UILayoutPriority
        
        public init(integerLiteral value: IntegerLiteralType) {
            self.value = CGFloat(value)
            self.priority = .fittingSizeLevel
        }
        
        public init(floatLiteral value: Double) {
            self.value = CGFloat(value)
            self.priority = .fittingSizeLevel
        }
        
        /// Creates a proposal to fit a size with a particular priority.
        public init(_ value: CGFloat,
                    priority: UILayoutPriority = .fittingSizeLevel) {
            self.value = value
            self.priority = priority
        }
        
        /// Creates an optional proposal to fit a size with a particular priority.
        public init?(_ value: CGFloat?,
                     priority: UILayoutPriority = .fittingSizeLevel) {
            guard let value = value else { return nil }
            self.value = value
            self.priority = priority
        }
    }

    // MARK: - _LayoutContainer

    /// Contains a view within a proposed layout.
    public struct _LayoutContainer: UIViewRepresentable {
        var layout: ProposedLayout
        var content: Content
        var onChange: ContextCallback?
        var onFinish: Callback?
        
        /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
        public func makeCoordinator() -> _Coordinator {
            Coordinator(onStart: .none, onFinish: onFinish)
        }
        
        /// Creates the view object and configures its initial state.
        public func makeUIView(context: Context) -> _LayoutContainerView {
            context.coordinator.makeLayoutContainer(with: content)
        }
        
        /// Updates the state of the specified view with new information from SwiftUI.
        public func updateUIView(_ layoutContainer: _LayoutContainerView, context: Context) {
            context.transaction.animateChanges { animated in
                print(animated, context.transaction.animation as Any, context.transaction.parsedAnimation as Any)
                self.onChange?(layoutContainer.view, context)
                layoutContainer.systemLayoutFittingSize(layout)
            }
        }
        
        /// Cleans up the presented UIKit view (and coordinator) in anticipation of their removal.
        public static func dismantleUIView(_ container: _LayoutContainerView, coordinator: _Coordinator) {
            coordinator.finish()
        }
        
        /// Returns the size of the composite view, given a proposed size and the view’s subviews.
        @available(iOS 16.0, *)
        public func sizeThatFits(_ size: ProposedViewSize, uiView layoutContainer: _LayoutContainerView, context: Context) -> CGSize? {
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
            // https://developer.apple.com/documentation/swiftui/proposedviewsize/replacingunspecifieddimensions(by:)
            guard let proposal = proposal, proposal.value != 10 else {
                // If we get this far we're better trusing our own layout settings.
                return original
            }
            return proposal
        }
    }

    // MARK: - Coordinator

    /// Responsible for managing a UIKit view lifecycle and interfacing with SwiftUI.
    public final class _Coordinator: NSObject {
        private(set) var container: _LayoutContainerView?
        let onStart: Callback?
        let onFinish: Callback?
        
        init(onStart: Callback?,
             onFinish: Callback?) {
            self.onStart = onStart
            self.onFinish = onFinish
        }
        
        func makeLayoutContainer(with content: Content) -> _LayoutContainerView {
            guard let cached = container else {
                let layoutContainer = _LayoutContainerView(content())
                onStart?(layoutContainer.view)
                self.container = layoutContainer
                return layoutContainer
            }
            return cached
        }
        
        func finish() {
            guard let contentView = container?.view else { return }
            onFinish?(contentView)
            container = nil
        }
    }

    // MARK: - _LayoutContainerView

    /// A container view that is able to calulate the size of its content based on different layout proposals.
    public final class _LayoutContainerView: UIView {
        let view: UIViewType
        
        private(set) var layout: ProposedLayout?
        
        private lazy var contentSize = view.intrinsicContentSize
        
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
        
        public func setupViews() {
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            layoutConstraints.forEach {
                $0.isActive = true
            }
        }
        
        override public var intrinsicContentSize: CGSize { contentSize }
        
        override public func invalidateIntrinsicContentSize() {
            super.invalidateIntrinsicContentSize()
            layout = .none
        }
        
        override public func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
            view.contentCompressionResistancePriority(for: axis)
        }
        
        override public func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
            view.contentHuggingPriority(for: axis)
        }
        
        @discardableResult
        func systemLayoutFittingSize(_ proposal: ProposedLayout) -> CGSize {
            let newSize = view.systemLayoutSizeFitting(
                proposal.size,
                withHorizontalFittingPriority: proposal.width.priority,
                verticalFittingPriority: proposal.height.priority)
            
            if newSize != contentSize, isValidSize(newSize.height), isValidSize(newSize.width) {
                invalidateIntrinsicContentSize()
                contentSize = newSize
                layout = proposal
            }
            return newSize
        }
        
        private func isValidSize(_ float: CGFloat) -> Bool {
            (CGFloat.compressedSize ... CGFloat.expandedSize).contains(float)
        }
    }
}

// MARK: - UILayoutPriority Extensions

extension UILayoutPriority {
    public static var uiKitViewDefault: UILayoutPriority = layoutResolvingLevelSize
    static let layoutResolvingLevelSize: UILayoutPriority = .init(950)
}

// MARK: - CGFloat Extensions

public extension CGFloat {
    /// As small as possible. Equivalent to `UIView.layoutFittingCompressedSize.width`.
    static var compressedSize: CGFloat { UIView.layoutFittingCompressedSize.width }
    /// As large as possible. Equivalent to `UIView.layoutFittingExpandedSize.width`.
    static var expandedSize: CGFloat { UIView.layoutFittingExpandedSize.width }
}

// MARK: - CGSize Extensions

public extension CGSize {
    /// As small as possible. Equivalent to `UIView.layoutFittingCompressedSize`.
    static var compressedSize: CGSize { UIView.layoutFittingCompressedSize }
    /// As large as possible. Equivalent to `UIView.layoutFittingExpandedSize`.
    static var expandedSize: CGSize { UIView.layoutFittingExpandedSize }
}

// MARK: - Previews

struct UIKitView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 36) {
                UIKitView {
                    UILabel()
                } onChange: {
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                    $0.attributedText = NSAttributedString(
                        string: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer",
                        attributes: [
                            .underlineStyle: NSNumber(value: 1),
                            .font: UIFont.preferredFont(forTextStyle: .headline),
                            .foregroundColor: UIColor.systemBackground,
                            .backgroundColor: UIColor.systemGreen.withAlphaComponent(0.25)
                        ]
                    )
                }
                .padding()
                .background(Color.accentColor)
                .cornerRadius(24)
                
                UIKitView {
                    UISwitch()
                } onChange: {
                    $0.backgroundColor = .systemRed.withAlphaComponent(0.1)
                }
                .fixedSize()
                
                UIKitView {
                    UISwitch()
                } onChange: {
                    $0.backgroundColor = .systemRed.withAlphaComponent(0.1)
                }
                
                HStack(spacing: 24) {
                    // Body Text
                    Text("Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type.")
                    
                    // Should look and behave exactly the same
                    UIKitView {
                        UILabel()
                    } onChange: {
                        $0.font = .preferredFont(forTextStyle: .body)
                        $0.adjustsFontForContentSizeCategory = true
                        $0.numberOfLines = 0
                        $0.text = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type."
                    }
                }
                
                HStack(spacing: 24) {
                    UIKitView {
                        UIImageView(image: .init(systemName: "checkmark"))
                    } onChange: {
                        $0.contentMode = .scaleAspectFill
                    }
                    .padding()
                    .background(Color.primary.opacity(0.1))
                    .aspectRatio(contentMode: .fill)
                    
                    UIKitView {
                        UILabel()
                    } onChange: {
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
