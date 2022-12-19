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

public extension UIKitView {
    /// A value with a particular priority.
    struct LayoutFittingSize: Equatable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
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
}

public extension CGFloat {
    /// As small as possible. Equivalent to `UIView.layoutFittingCompressedSize.width`.
    static var compressedSize: CGFloat { UIView.layoutFittingCompressedSize.width }
    /// As large as possible. Equivalent to `UIView.layoutFittingExpandedSize.width`.
    static var expandedSize: CGFloat { UIView.layoutFittingExpandedSize.width }
}

public extension CGSize {
    /// As small as possible. Equivalent to `UIView.layoutFittingCompressedSize`.
    static var compressedSize: CGSize { UIView.layoutFittingCompressedSize }
    /// As large as possible. Equivalent to `UIView.layoutFittingExpandedSize`.
    static var expandedSize: CGSize { UIView.layoutFittingExpandedSize }
}
