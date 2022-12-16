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
                    _ priority: UILayoutPriority = .fittingSizeLevel) {
            self.value = value
            self.priority = priority
        }
        
        public init?(_ value: CGFloat?,
                    _ priority: UILayoutPriority = .fittingSizeLevel) {
            guard let value = value else { return nil }
            self.value = value
            self.priority = priority
        }

        /// Equivalent to `UIView.layoutFittingCompressedSize` (0)
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func compressedSize(_ priority: UILayoutPriority = .fittingSizeLevel) -> Self {
            .init(UIView.layoutFittingCompressedSize.height, priority)
        }

        /// Equivalent to `UIView.layoutFittingExpandedSize`
        ///
        /// - Parameter priority: The priority for constraints. Specify fittingSizeLevel to get a size that is as close as possible to the targetSize.
        public static func expandedSize(_ priority: UILayoutPriority = .fittingSizeLevel) -> Self {
            .init(UIView.layoutFittingExpandedSize.height, priority)
        }
    }
}
