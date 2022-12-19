// MIT License
//
// Copyright (c) 2022 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UILayoutPriority {
    public static var uiKitViewDefault: UILayoutPriority = layoutResolvingLevelSize
    static let layoutResolvingLevelSize: UILayoutPriority = .init(950)
}

public extension UIKitView {
    /// Contains layout information for a view object.
    struct ProposedLayout: Equatable {
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
}
