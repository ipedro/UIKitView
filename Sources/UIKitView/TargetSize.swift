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

extension UIKitView {
    /// Defines a layout proposal for a view object.
    public struct TargetSize: Equatable {
        public var width: Value
        public var height: Value
        
        var size: CGSize { .init(width: width.value, height: height.value) }
        
        public init(width: Value = .compressedSize(),
                    height: Value = .compressedSize()) {
            self.width = width
            self.height = height
        }
        
        public init(size: CGSize,
                    horizontalFit: UILayoutPriority = .fittingSizeLevel,
                    verticalFit: UILayoutPriority = .fittingSizeLevel) {
            width = .init(size.width, priority: horizontalFit)
            height = .init(size.height, priority: verticalFit)
        }
        
        /// Fit the container to the size of the device that the app is running on.
        public static func device(horizontalFit: UILayoutPriority = .fittingSizeLevel,
                                  verticalFit: UILayoutPriority = .fittingSizeLevel) -> Self {
            .init(size: UIScreen.main.bounds.size, horizontalFit: horizontalFit, verticalFit: verticalFit)
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
}
