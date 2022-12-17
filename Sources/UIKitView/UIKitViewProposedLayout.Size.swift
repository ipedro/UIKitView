import UIKit

/// Defines a UIView layout proposal size
public extension UIKitViewProposedLayout {
    struct Size: Equatable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
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

        public init(_ value: CGFloat,
                    priority: UILayoutPriority = .fittingSizeLevel) {
            self.value = value
            self.priority = priority
        }

        /// As small as possible. Equivalent to `UIView.layoutFittingCompressedSize.width`.
        ///
        /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func compressedSize(_ priority: UILayoutPriority = .fittingSizeLevel) -> Self {
            .init(UIView.layoutFittingCompressedSize.width, priority: priority)
        }

        /// As large as possible. Equivalent to `UIView.layoutFittingExpandedSize.width`.
        ///
        /// The layout priority for each axis is used to indicate which constraints are more important to the constraint-based layout system, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func expandedSize(_ priority: UILayoutPriority = .fittingSizeLevel) -> Self {
            .init(UIView.layoutFittingExpandedSize.width, priority: priority)
        }
    }
}
