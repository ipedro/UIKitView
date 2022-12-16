import UIKit

/// Defines a UIView layout proposal
public struct UIKitViewProposedLayout: Equatable {
    public var width: Size
    public var height: Size
    public var size: CGSize { .init(width: width.value, height: height.value) }

    public init(width: Size = .compressedSize(),
                height: Size = .compressedSize()) {
        self.width = width
        self.height = height
    }

    public init(targetSize: CGSize,
                horizontalFit: UILayoutPriority = .fittingSizeLevel,
                verticalFit: UILayoutPriority = .fittingSizeLevel) {
        width = .init(targetSize.width, horizontalFit)
        height = .init(targetSize.height, verticalFit)
    }

    /// As small as possible. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingCompressedSize)`.
    ///
    /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
    public static func compressedLayout(horizontalFit: UILayoutPriority = .fittingSizeLevel,
                                        verticalFit: UILayoutPriority = .fittingSizeLevel) -> Self {
        .init(width: .compressedSize(horizontalFit), height: .compressedSize(verticalFit))
    }

    /// As large as possible. Equivalent to `systemLayoutFittingSize(UIView.layoutFittingExpandedSize)`.
    ///
    /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
    public static func expandedLayout(horizontalFit: UILayoutPriority = .fittingSizeLevel,
                                      verticalFit: UILayoutPriority = .fittingSizeLevel) -> Self {
        .init(width: .expandedSize(horizontalFit), height: .expandedSize(verticalFit))
    }
}
