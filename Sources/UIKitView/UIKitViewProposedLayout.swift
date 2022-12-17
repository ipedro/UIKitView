import UIKit

/// Defines a layout proposal for a view object.
public struct UIKitViewProposedLayout: Equatable {
    public var width: Size
    public var height: Size
    public var size: CGSize { .init(width: width.value, height: height.value) }
    
    public init(width: Size = .compressedSize(),
                height: Size = .compressedSize()) {
        self.width = width
        self.height = height
    }
    
    public init(size: CGSize,
                horizontalFit: UILayoutPriority = .fittingSizeLevel,
                verticalFit: UILayoutPriority = .fittingSizeLevel) {
        width = .init(size.width, priority: horizontalFit)
        height = .init(size.height, priority: verticalFit)
    }
    
    /// The narrowest and shortest size. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingCompressedSize)`.
    ///
    /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
    ///
    /// - Parameter priority: The priority for constraints. Specify `.fittingSizeLevel` to get a size that is as close as possible to the target size.
    public static func compressed(horizontalFit: UILayoutPriority = .fittingSizeLevel,
                                  verticalFit: UILayoutPriority = .fittingSizeLevel) -> Self {
        .init(width: .compressedSize(horizontalFit), height: .compressedSize(verticalFit))
    }
    
    /// The wide and tall as possible. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingExpandedSize)`.
    
    /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
    ///
    /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
    public static func expanded(horizontalFit: UILayoutPriority = .fittingSizeLevel,
                                verticalFit: UILayoutPriority = .fittingSizeLevel) -> Self {
        .init(width: .expandedSize(horizontalFit), height: .expandedSize(verticalFit))
    }
}
